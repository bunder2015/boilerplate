song_index_New20song = 0

song_list:
  .dw _New20song

instrument_list:
  .dw _New_instrument_0
  .dw _square1_1
  .dw _square2_2
  .dw _triangle_3
  .dw _noise_4
  .dw silent_5

_New_instrument_0:
  .db 5,7,9,11,ARP_TYPE_ABSOLUTE
  .db 0,ENV_STOP
  .db 0,ENV_STOP
  .db 0,DUTY_ENV_STOP
  .db ENV_STOP

_square1_1:
  .db 5,14,16,18,ARP_TYPE_ABSOLUTE
  .db 11,9,8,7,6,3,2,0,ENV_STOP
  .db 0,ENV_STOP
  .db 0,DUTY_ENV_STOP
  .db ENV_STOP

_square2_2:
  .db 5,7,9,11,ARP_TYPE_ABSOLUTE
  .db 11,ENV_STOP
  .db 0,ENV_STOP
  .db 0,DUTY_ENV_STOP
  .db ENV_STOP

_triangle_3:
  .db 5,7,9,11,ARP_TYPE_ABSOLUTE
  .db 15,ENV_STOP
  .db 0,ENV_STOP
  .db 0,DUTY_ENV_STOP
  .db ENV_STOP

_noise_4:
  .db 5,7,9,11,ARP_TYPE_ABSOLUTE
  .db 9,ENV_STOP
  .db 0,ENV_STOP
  .db 0,DUTY_ENV_STOP
  .db ENV_STOP

silent_5:
  .db 5,7,9,11,ARP_TYPE_ABSOLUTE
  .db 0,ENV_STOP
  .db 0,ENV_STOP
  .db 0,DUTY_ENV_STOP
  .db ENV_STOP

_New20song:
  .db 0
  .db 6
  .db 0
  .db 5
  .dw _New20song_square1
  .dw _New20song_square2
  .dw _New20song_triangle
  .dw _New20song_noise
  .dw 0

_New20song_square1:
_New20song_square1_loop:
  .db CAL,low(_New20song_square1_0),high(_New20song_square1_0)
  .db GOT
  .dw _New20song_square1_loop

_New20song_square2:
_New20song_square2_loop:
  .db CAL,low(_New20song_square2_0),high(_New20song_square2_0)
  .db GOT
  .dw _New20song_square2_loop

_New20song_triangle:
_New20song_triangle_loop:
  .db CAL,low(_New20song_triangle_0),high(_New20song_triangle_0)
  .db GOT
  .dw _New20song_triangle_loop

_New20song_noise:
_New20song_noise_loop:
  .db CAL,low(_New20song_noise_0),high(_New20song_noise_0)
  .db GOT
  .dw _New20song_noise_loop

_New20song_square1_0:
  .db STI,1,SLC,C3,STI,5,SLL,52,A0
  .db RET

_New20song_square2_0:
  .db STI,5,SL0,A0,STI,2,SLC,C3,STI,5,SLL,36,A0
  .db RET

_New20song_triangle_0:
  .db STI,5,SLL,32,A0,STI,3,SLC,C2,STI,5,SLL,20,A0
  .db RET

_New20song_noise_0:
  .db STI,5,SLL,48,A0,STI,4,SLC,1,STI,5,SL4,A0
  .db RET

