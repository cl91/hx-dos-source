
// HX's WSOCK32 emulation dll
// based on WatTCP, compiled with OW 1.4

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tcp.h>
#include <netdb.h>
#include <sys/socket.h>
#include "errors.h"
#include "version.h"

__declspec(dllimport) void __stdcall OutputDebugStringA(char *);
__declspec(dllimport) int __stdcall CloseHandle(int);
__declspec(dllimport) int __stdcall CreateSocketHandle(void);
__declspec(dllimport) int __cdecl wsprintfA(char *, char *, ...);
__declspec(dllimport) int __stdcall GetModuleHandleA(char *);
__declspec(dllimport) int __stdcall GetModuleFileNameA(unsigned int, char *, int);
int __stdcall _WSASetLastError(int iError);

// some structures which require translation
// wshostent/wsservent/wfd_set: Winsocket
// wthostent/wtservent/fd_set: watt-32

// hostent structures

typedef struct _wshostent {
    char * h_name;
    char * * h_aliases;
    short h_addrtype;
    short h_length;
    char * * h_addr_list;
} wshostent, *pwshostent;

typedef struct _wthostent {
    char * h_name;
    char * * h_aliases;
    int h_addrtype;
    int h_length;
    char * * h_addr_list;
} wthostent;

// servent structures

typedef struct _wsservent {
    char * s_name;
    char * s_aliases;
    short s_port;
    char * s_proto;
} wsservent, *pwsservent;

typedef struct _wtservent {
    char * s_name;
    char * s_aliases;
    int s_port;
    char * s_proto;
} wtservent;

// the Winsocket fs_set type (this is not a bitfield)

#ifndef FD_SETSIZE
#define FD_SETSIZE 64
#endif

typedef struct _wfd_set {
    int fd_count;
    int fd_array[FD_SETSIZE];
} wfd_set;

// the SOCKET is allocated in dkrnl32 !!
// this is needed because a socket handle is a valid parameter for
// DuplicateHandle() and CloseHandle()
// the first 2 fields are used by dkrnl32.dll!!

typedef struct _SOCKET {
    DWORD dwType;       // dkrnl32 field, don't touch
    DWORD dwRefCnt;     // dkrnl32 field, decremented by destructor
    int hSocket;        // WatTCP socket handle
} SOCKET, *LPSOCKET;

// another translation issue are the error codes

extern int errno;

const short errtable[] = {
//    ENOENT, WSAENOENT,
    EBADF, WSAEBADF,
    ENOMEM, WSAEINTR,
	EACCES, WSAEACCES,
    EINVAL, WSAEINVAL,
	EWOULDBLOCK, WSAEWOULDBLOCK,
	EINPROGRESS, WSAEINPROGRESS,
	EALREADY, WSAEALREADY,
	ENOTSOCK, WSAENOTSOCK,
	EDESTADDRREQ, WSAEDESTADDRREQ,
	EMSGSIZE, WSAEMSGSIZE,
	EPROTOTYPE, WSAEPROTOTYPE,
	ENOPROTOOPT, WSAENOPROTOOPT,
	EPROTONOSUPPORT, WSAEPROTONOSUPPORT,
	ESOCKTNOSUPPORT, WSAESOCKTNOSUPPORT,
	EOPNOTSUPP, WSAEOPNOTSUPP,
	EPFNOSUPPORT, WSAEPFNOSUPPORT,
	EAFNOSUPPORT, WSAEAFNOSUPPORT,
	EADDRINUSE, WSAEADDRINUSE,
	EADDRNOTAVAIL, WSAEADDRNOTAVAIL,
	ENETDOWN, WSAENETDOWN,
	ENETUNREACH, WSAENETUNREACH,
	ENETRESET, WSAENETRESET,
	ECONNABORTED, WSAECONNABORTED,
	ECONNRESET, WSAECONNRESET,
	ENOBUFS, WSAENOBUFS,
	EISCONN, WSAEISCONN,
	ENOTCONN, WSAENOTCONN,
	ESHUTDOWN, WSAESHUTDOWN,
	ETIMEDOUT, WSAETIMEDOUT,
	ECONNREFUSED, WSAECONNREFUSED,
	EHOSTDOWN, WSAEHOSTDOWN,
	EHOSTUNREACH, WSAEHOSTUNREACH,
	ESTALE, WSAESTALE,
	EREMOTE, WSAEREMOTE,
//	EBADRPC, WSAEBADRPC,
	-1
};

#define WSADESC "HX WSock32 emulation, v" WSVERSION ", based on WatTCP"

BYTE g_bInit = 0;   // != 0 if WSAStartup has been called

#ifdef _DEBUG
char g_szDbgText[128];
#define  DebugOut( p1 ) OutputDebugStringA( p1 )
#define DebugOut1( p1, p2 ) wsprintfA(g_szDbgText, p1, p2); OutputDebugStringA(g_szDbgText)
#define DebugOut2( p1, p2, p3 ) wsprintfA(g_szDbgText, p1, p2, p3); OutputDebugStringA(g_szDbgText)
#define DebugOut3( p1, p2, p3, p4 ) wsprintfA(g_szDbgText, p1, p2, p3, p4); OutputDebugStringA(g_szDbgText)
#define DebugOut4( p1, p2, p3, p4, p5 ) wsprintfA(g_szDbgText, p1, p2, p3, p4, p5); OutputDebugStringA(g_szDbgText)
#define DebugOut5( p1, p2, p3, p4, p5, p6 ) wsprintfA(g_szDbgText, p1, p2, p3, p4, p5, p6); OutputDebugStringA(g_szDbgText)
#else
#define  DebugOut( p1 )
#define DebugOut1( p1, p2 )
#define DebugOut2( p1, p2 , p3 )
#define DebugOut3( p1, p2 , p3, p4 )
#define DebugOut4( p1, p2 , p3, p4, p5 )
#define DebugOut5( p1, p2 , p3, p4, p5, p6 )
#endif

#if 0
int __stdcall MessageBoxA(int hwnd, char * pszText, char * pszCaption, int dwType)
{
    fprintf(stderr, "WSOCK32: %s\n", pszText);
    return 1;
}
#endif

int __stdcall _destructor(LPSOCKET s)
{
    s->dwRefCnt--;
    if (!s->dwRefCnt) {
        closesocket(s->hSocket);
        return 1;   // allow dkrnl32 to free the object
    } else
        return 0;   // object must remain alive
}

// a socket is allocated on the internal kernel heap
// so this is DKRNL32 specific code. the destructor
// is called whenever CloseHandle(socket) is called.

typedef int __stdcall (* LPDESTRUCTOR)(LPSOCKET);

static void SetObjectDestructor(void * pKernelObject, LPDESTRUCTOR pDestructor)
{
    *((DWORD *)pKernelObject-1) = (DWORD)pDestructor;
    return;
}

// accept returns a socket handle!

LPSOCKET __stdcall _accept(LPSOCKET s, struct sockaddr * paddr, int * addrlen)
{
    LPSOCKET sock;
    int tmps;
    if (-1 != (tmps = accept(s->hSocket, paddr, addrlen))) {
        if (sock = (LPSOCKET)CreateSocketHandle()) {
            sock->hSocket = tmps;
            SetObjectDestructor(sock, _destructor);
        } else {
            closesocket(tmps);
            errno = ENOMEM;
            sock = (LPSOCKET)-1;
        }
    } else
        sock = (LPSOCKET)-1;
    DebugOut4("accept(%X, %X, %X)=%X\r\n", s, paddr, addrlen, sock);
    return sock;
}

int __stdcall _bind(LPSOCKET s, struct sockaddr * paddr, int addrlen)
{
    DebugOut3("bind(%X, %X, %X)\r\n", s, paddr, addrlen);
    return bind(s->hSocket, paddr, addrlen);
}

int __stdcall _closesocket(LPSOCKET s)
{
    int rc = SOCKET_ERROR;
    if (s) {
        if (CloseHandle((int)s))
            rc = 0;
        else
            errno = ENOTSOCK;
    } else
        errno = ENOTSOCK;

    DebugOut2("closesocket(%X)=%X\r\n", s, rc);
    return rc;
}

int __stdcall _connect(LPSOCKET s, struct sockaddr * name, int namelen)
{
#ifdef _DEBUG
    int rc = connect(s->hSocket, name, namelen);
    DebugOut4("connect(%X, %X, %X)=%X\r\n", s, name, namelen, rc);
    return rc;
#else
    return connect(s->hSocket, name, namelen);
#endif
}

int __stdcall __getpeername(LPSOCKET s, struct sockaddr * name, int * namelen)
{
    DebugOut3("getpeername(%X, %X, %X)\r\n", s, name, namelen);
    return getpeername(s->hSocket, name, namelen);
}

int __stdcall __getsockname(LPSOCKET s, struct sockaddr * name, int * namelen)
{
    DebugOut3("getsockname(%X, %X, %X)\r\n", s, name, namelen);
    return getsockname(s->hSocket, name, namelen);
}

int __stdcall __getsockopt(LPSOCKET s, int level, int optname, char * optval, int * optlen)
{
    DebugOut4("getsockopt(%X, %X, %X, %X)\r\n", s, level, optname, optval);
    return getsockopt(s->hSocket, level, optname, optval, optlen);
}

int __stdcall _htonl(int hostlong)
{
#ifdef _DEBUG
    int rc = htonl(hostlong);
    DebugOut2("htonl(%X)=%X\r\n", hostlong, rc);
    return rc;
#else
    return htonl(hostlong);
#endif
}

int __stdcall _htons(short hostshort)
{
#ifdef _DEBUG
    int rc = htons(hostshort);
    DebugOut2("htons(%X)=%X\r\n", hostshort, rc);
    return rc;
#else
    return htons(hostshort);
#endif
}

DWORD __stdcall __inet_addr(char * cp)
{
    DWORD dwAddr = _inet_addr(cp);
    if (!dwAddr)
        dwAddr = 0xFFFFFFFF;
    DebugOut2("inet_addr(%s)=%X\r\n", cp, dwAddr);
    return dwAddr;
}

char * __stdcall __inet_ntoa(DWORD in)
{
    DebugOut1("inet_ntoa(%X)\r\n", in);
    return _inet_ntoa( NULL, in);
}

int __stdcall _ioctlsocket(LPSOCKET s, long cmd, char * argp)
{
    DebugOut3("ioctlsocket(%X, %X, %X)\r\n", s, cmd, argp);
    if (!s) {
        errno = ENOTSOCK;
        return SOCKET_ERROR;
    };
    return ioctlsocket(s->hSocket, cmd, argp);
}

int __stdcall _listen(LPSOCKET s, int backlog)
{
    DebugOut2("listen(%X, %X)\r\n", s, backlog);
    return listen(s->hSocket, backlog);
}

int __stdcall _ntohl(int netlong)
{
    DebugOut1("ntohl(%X)\r\n", netlong);
    return ntohl(netlong);
}

int __stdcall _ntohs(int netshort)
{
    DebugOut1("ntohs(%X)\r\n", netshort);
    return ntohs(netshort);
}

int __stdcall _recv(LPSOCKET s, void * buf, int len, int flags)
{
    DebugOut2("recv(%X, %X)\r\n", s, buf);
    return recv(s->hSocket, buf, len, flags);
}

int __stdcall _recvfrom(LPSOCKET s, void * buf, int len, int flags, struct sockaddr * from, int * fromlen)
{
    DebugOut("recvfrom()\r\n");
    return recvfrom(s->hSocket, buf, len, flags, from, fromlen);
}

// the select() function needs heavy translation.
// this is because the fd_set structure is totally different:
// in Winsocket it is an array of DWORDS, with size of array as 1. dword
// in WatTCP it is a bitfield

int __stdcall _select(int nfds, wfd_set * readfds, wfd_set * writefds, wfd_set * excfds, struct timeval * timeout)
{
    int rc;
    int _nfds = 0;
    int i;
    int * pi;
    int * pi2;
    LPSOCKET s;
    struct fd_set tmpread;
    struct fd_set tmpwrite;
    struct fd_set tmpexc;
    struct fd_set * ptmpread = 0;
    struct fd_set * ptmpwrite = 0;
    struct fd_set * ptmpexc = 0;

    if (readfds && readfds->fd_count) {
        DebugOut3("before select(): read=%X [%X %X]\r\n", readfds->fd_count, readfds->fd_array[0], readfds->fd_array[1]);
        memset(&tmpread,0,sizeof(fd_set));
        for (i = readfds->fd_count, pi = readfds->fd_array;i;i--,pi++) {
            if (!(s = (LPSOCKET)(*pi))) {
                _WSASetLastError(WSAENOTSOCK);
                return SOCKET_ERROR;
            }
            FD_SET(s->hSocket, &tmpread);
            if (s->hSocket > _nfds)
                _nfds = s->hSocket;
        }
        ptmpread = &tmpread;
    };
    if (writefds && writefds->fd_count) {
        DebugOut3("before select(): write=%X [%X %X]\r\n", writefds->fd_count, writefds->fd_array[0], writefds->fd_array[1]);
        memset(&tmpwrite,0,sizeof(fd_set));
        for (i = writefds->fd_count, pi = writefds->fd_array;i;i--,pi++) {
            s = (LPSOCKET)(*pi);
            FD_SET(s->hSocket, &tmpwrite);
            if (s->hSocket > _nfds)
                _nfds = s->hSocket;
        }
        ptmpwrite = &tmpwrite;
    };
    if (excfds && excfds->fd_count) {
        DebugOut3("before select(): exc=%X [%X %X]\r\n", excfds->fd_count, excfds->fd_array[0], excfds->fd_array[1]);
        memset(&tmpexc,0,sizeof(fd_set));
        for (i = excfds->fd_count, pi = excfds->fd_array;i;i--,pi++) {
            s = (LPSOCKET)(*pi);
            FD_SET(s->hSocket, &tmpexc);
            if (s->hSocket > _nfds)
                _nfds = s->hSocket;
        }
        ptmpexc = &tmpexc;
    };
    _nfds++;
    if (_nfds > FD_SETSIZE)
        _nfds = FD_SETSIZE;
    rc = select_s(_nfds, ptmpread, ptmpwrite, ptmpexc, timeout);
    if (rc != SOCKET_ERROR) {
        if (ptmpread) {
            i = readfds->fd_count;
            readfds->fd_count = 0;
            DebugOut4("select(): rd fd=%X %X %X %X\r\n", tmpread.fd_bits[0], tmpread.fd_bits[1], tmpread.fd_bits[2], tmpread.fd_bits[3]);
            if (rc)
                for (pi = readfds->fd_array, pi2 = pi;i;i--,pi++) {
                    s = (LPSOCKET)(*pi);
                    if (FD_ISSET(s->hSocket, ptmpread)) {
                        *pi2++ = *pi;
                        readfds->fd_count++;
                    };
                };
            DebugOut3("select(): read=%X [%X %X]\r\n", readfds->fd_count, readfds->fd_array[0], readfds->fd_array[1]);
        };
        if (ptmpwrite) {
            i = writefds->fd_count;
            writefds->fd_count = 0;
            DebugOut4("select(): wr fd=%X %X %X %X\r\n", tmpwrite.fd_bits[0], tmpwrite.fd_bits[1], tmpwrite.fd_bits[2], tmpwrite.fd_bits[3]);
            if (rc)
                for (pi = writefds->fd_array, pi2 = pi;i;i--,pi++) {
                    s = (LPSOCKET)(*pi);
                    if (FD_ISSET(s->hSocket, &tmpwrite)) {
                        *pi2++ = *pi;
                        writefds->fd_count++;
                    };
                };
            DebugOut3("select(): write=%X [%X %X]\r\n", writefds->fd_count, writefds->fd_array[0], writefds->fd_array[1]);
        };
        if (ptmpexc) {
            i = excfds->fd_count;
            excfds->fd_count = 0;
            if (rc)
                for (pi = excfds->fd_array, pi2 = pi;i;i--,pi++) {
                    s = (LPSOCKET)(*pi);
                    if (FD_ISSET(s->hSocket, &tmpexc)) {
                        *pi2++ = *pi;
                        excfds->fd_count++;
                    };
                };
            DebugOut3("select(): exc=%X [%X %X]\r\n", excfds->fd_count, excfds->fd_array[0], excfds->fd_array[1]);
        };
    }
    DebugOut5("select(%X, %X, %X, %X)=%X\r\n", nfds, readfds, writefds, excfds, rc);
    return rc;
}

int __stdcall _send(LPSOCKET s, void * buf, int len, int flags)
{
    DebugOut2("send(%X, %X)\r\n", s, buf);
    return send(s->hSocket, buf, len, flags);
}

int __stdcall _sendto(LPSOCKET s, void * buf, int len, int flags, struct sockaddr * to, int tolen)
{
    DebugOut("sendto()\r\n");
    return sendto(s->hSocket, buf, len, flags, to, tolen);
}

int __stdcall _setsockopt(LPSOCKET s, int level, int optname, char * optval, int optlen)
{
#if 1 // def _DEBUG
    int rc;
    if (!s) {
        errno = ENOTSOCK;
        rc = -1;
    } else
        rc = setsockopt(s->hSocket, level, optname, optval, optlen);
    DebugOut4("setsockopt(%X, %X, %X)=%X\r\n", s, level, optname, rc);
    return rc;
#else
    return setsockopt(s->hSocket, level, optname, optval, optlen);
#endif
}

int __stdcall _shutdown(LPSOCKET s, int how)
{
    DebugOut2("shutdown(%X, %X)\r\n", s, how);
    return shutdown(s->hSocket, how);
}

LPSOCKET __stdcall _socket(int af, int type, int protocol)
{
    LPSOCKET sock;
    if (sock = (LPSOCKET)CreateSocketHandle()) {
        sock->hSocket = socket(af, type, protocol);
        if (sock->hSocket == INVALID_SOCKET) {
            CloseHandle((int)sock);
            sock = 0;
        } else
            SetObjectDestructor(sock, _destructor);
    } else {
        errno = ENOMEM;
        sock = (LPSOCKET)-1;
    }
    DebugOut4("socket(%X, %X, %X)=%X\r\n", af, type, protocol, sock);
    return sock;
}

//////////////////////////////////////////////////////////////////////////

void copyhe(wshostent * pwshe, wthostent * pwthe)
{
    pwshe->h_name      = pwthe->h_name;
    pwshe->h_aliases   = pwthe->h_aliases;
    pwshe->h_addrtype  = pwthe->h_addrtype;
    pwshe->h_length    = pwthe->h_length;
    pwshe->h_addr_list = pwthe->h_addr_list;
    return;
}

void copyse(wsservent * pwsse, wtservent * pwtse)
{
    pwsse->s_name      = pwtse->s_name;
    pwsse->s_aliases   = pwtse->s_aliases;
    pwsse->s_port      = pwtse->s_port;
    pwsse->s_proto     = pwtse->s_proto;
    return;
}

pwshostent __stdcall _gethostbyaddr(char * addr, int len, int type)
{
    static wshostent wshe;
    wthostent * pwthe;
    DebugOut2("gethostbyaddr(%X,%X)\r\n", addr, len);
#if 1
    pwthe = (wthostent *)gethostbyaddr(addr, len, type);
    if (pwthe) {
        copyhe(&wshe, pwthe);
        return &wshe;
    } else
        return 0;
#else
    return gethostbyaddr(addr, len, type);
#endif
}

pwshostent __stdcall _gethostbyname(char * name)
{
    static wshostent wshe;
    wthostent * pwthe;

#if 1
    pwthe = (wthostent *)gethostbyname(name);
    if (pwthe) {
        copyhe(&wshe, pwthe);
        DebugOut2("gethostbyname(%s)=%X\r\n", name, *(DWORD *)(wshe.h_addr_list[0]));
        return &wshe;
    } else
        DebugOut1("gethostbyname(%s)=0\r\n", name);
        errno = WSAHOST_NOT_FOUND;
        return 0;
#else
    return gethostbyname(name);
#endif
}

struct protoent * __stdcall _getprotobyname(char * name)
{
    DebugOut1("getprotobyname(%s)\r\n", name);
    return getprotobyname(name);
}

struct protoent * __stdcall _getprotobynumber(int number)
{
    DebugOut1("getprotobynumber(%X)\r\n", number);
    return getprotobynumber(number);
}

pwsservent __stdcall _getservbyname(char * name, char * proto)
{
    static wsservent wsse;
    wtservent * pwtse;
    DebugOut2("getservbyname(%s, %s)\r\n", name, proto);
#if 1
    pwtse = (wtservent *)getservbyname(name, proto);
    if (pwtse) {
        copyse(&wsse, pwtse);
        return &wsse;
    } else
        return 0;
#else
    return getservbyname(name, proto);
#endif
}

pwsservent __stdcall _getservbyport(int port, char * proto)
{
    static wsservent wsse;
    wtservent * pwtse;
    DebugOut2("getservbyport(%X, %s)\r\n", port, proto);
#if 1
    pwtse = (wtservent *)getservbyport(port, proto);
    if (pwtse) {
        copyse(&wsse, pwtse);
        return &wsse;
    } else
        return 0;
#else
    return getservbyport(port, proto);
#endif
}

int __stdcall _gethostname(char * pname, int namelen)
{
    DebugOut2("gethostname(%X, %X)\r\n", pname, namelen);
    return gethostname(pname, namelen);
}


//////////////////////////////////////////////////////////////////////////

int __stdcall _WSAGetLastError(void)
{
    const short * ps;
    short serrno = errno;

    for (ps = errtable;*ps != -1;ps = ps+2)
        if (*ps == serrno) {
            DebugOut1("WSAGetLastError()=%u\r\n", (int)(*(ps+1)));
            return (int)(*(ps+1));
        }

    DebugOut1("WSAGetLastError()=%u\r\n", errno);
    return errno;
}

int __stdcall _WSASetLastError(int iError)
{
    errno = iError;
    return iError;
}

#define WSADESCRIPTION_LEN      256
#define WSASYS_STATUS_LEN       128

typedef struct WSAData {
        unsigned short          wVersion;
        unsigned short          wHighVersion;
        char                    szDescription[WSADESCRIPTION_LEN+1];
        char                    szSystemStatus[WSASYS_STATUS_LEN+1];
        unsigned short          iMaxSockets;
        unsigned short          iMaxUdpDg;
        char *                  lpVendorInfo;
} WSADATA;

int __stdcall _WSAStartup(int wVersion, WSADATA * lpWSAData)
{
    DebugOut2("WSAStartup(%X,%X)\r\n", wVersion, lpWSAData);
    if (!g_bInit) {
        g_bInit = 1;
        if (!sock_init()) {
            lpWSAData->wVersion = 0x101;
            lpWSAData->wHighVersion = 0x202;
            strcpy(lpWSAData->szDescription, WSADESC);
            strcpy(lpWSAData->szSystemStatus, "On DOS");
            lpWSAData->iMaxSockets = 0x7fff;
            lpWSAData->iMaxUdpDg = 0xffbb;
            lpWSAData->lpVendorInfo = 0;
        } else
            return WSASYSNOTREADY;
    }
    return 0;
}

int __stdcall _WSACleanup(void)
{
    DebugOut("WSACleanup()r\n");
    if (g_bInit) {
        sock_exit();
        g_bInit = 0;
        return 0;
    } else {
        _WSASetLastError(WSANOTINITIALISED);
        return SOCKET_ERROR;
    }
}

int __stdcall _WSASetBlockingHook(int fnHookproc)
{
    DebugOut1("WSASetBlockingHook(%X)\r\n", fnHookproc);
    _WSASetLastError(WSAENETDOWN);
    return 0;
}

int __stdcall _WSAUnhookBlockingHook(void)
{
    DebugOut("WSAUnhookBlockingHook()\r\n");
    _WSASetLastError(WSAENETDOWN);
    return SOCKET_ERROR;
}

int __stdcall _WSACancelBlockingCall(void)
{
    DebugOut("WSACancelBlockingHook()\r\n");
    _WSASetLastError(WSAENETDOWN);
    return SOCKET_ERROR;
}

int __stdcall _WSAIsBlocking(void)
{
    DebugOut("WSAIsBlocking()=0\r\n");
    return 0;
}

int __stdcall _WSAAsyncGetHostByName(DWORD hWnd, DWORD wMsg, char * name, char * buf, int buflen)
{
    DebugOut("WSAAsyncGetHostByName()=0\r\n");
    return 0;
}

int __stdcall _WSACancelAsyncRequest(DWORD hTask)
{
    DebugOut("WSACancelAsyncRequest()=0\r\n");
    return 0;
}

// __WSAFDIsSet() is called by macro FD_ISSET()

int __stdcall ___WSAFDIsSet(LPSOCKET s, wfd_set * pfd)
{
    int rc = 0;
    int i;
    for (i = 0;i < pfd->fd_count;i++)
        if (pfd->fd_array[i] == (int)s) {
            rc++;
            break;
        }
    DebugOut3("__WSAFDIsSet(%X, %X)=%X\r\n", s, pfd, rc);
    return rc;
}

// error formatting routine

#if 0
int __stdcall _s_perror(int i1, int i2)
{
    DebugOut2("s_perror(%X, %X)=0\r\n", i1, i2);
    return 0;
}
#endif

// wattcp wants a config file WATTCP.CFG.
// if there is no environment variable defined, define one
// so WATTCP.CFG is read from the directory where WSOCK32.DLL is
// stored. Do the same with ETC, from where wattcp tries to read
// SERVICES, NETWORKS, ETHERS, ...

void checkconfig()
{
    unsigned int hWSock;
    int iCnt;
    char ch;
    char szVar[260];
    if (!getenv("WATTCP.CFG")) {
        if (hWSock = GetModuleHandleA("WSOCK32")) {
            iCnt = GetModuleFileNameA(hWSock, szVar, sizeof(szVar));
            for (;iCnt;iCnt--) {
                ch = szVar[iCnt-1];
                szVar[iCnt-1] = 0;
                if (ch == '\\')
                    break;
            }
            setenv("WATTCP.CFG", szVar, 0);
        }
    }
    if (!getenv("ETC")) {
        if (hWSock = GetModuleHandleA("WSOCK32")) {
            iCnt = GetModuleFileNameA(hWSock, szVar, sizeof(szVar));
            for (;iCnt;iCnt--) {
                ch = szVar[iCnt-1];
                szVar[iCnt-1] = 0;
                if (ch == '\\')
                    break;
            }
            setenv("ETC", szVar, 0);
        }
    }
    return;
}

int __stdcall LibMain(int hModule, int dwReason, int dwReserved)
{
    if (dwReason == 1) {
        checkconfig();
#ifdef _DEBUG
        dbug_init();
#endif
    }
    return 1;
}
