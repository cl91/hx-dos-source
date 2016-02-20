      *
       identification division.
      *
       program-id. sample1.
      *
       data division.
      *
       working-storage section.
      *
        01 text1 pic x(14) value "Hello, world"&x'0D0A'.
        01 textsize pic 9(4) comp.
      *
       procedure division.
      *
          move 14 to textsize
          call "CBL_WRITE_SCR_TTY" using text1 textsize
      *
          goback.
