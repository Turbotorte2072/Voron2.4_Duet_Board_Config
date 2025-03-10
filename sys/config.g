;; system and network --------------------------------------

M550 PVoron 2.4			; hostname
M552 S1	
M586 P2 S1 R23 T0	; enable telnet
M586 P1 S1 R20 T0	; enable ftp
M555 P2			; set Marlin output mode

G21			; millimeter units
G90			; absolute tool coordinates
M83			; relative extruder coordinates
;; M80          ; sets pin in the power on state
M80 C"pson"  ; allocates the pin and sets the pin in the power on state.
;; M80 C"!pson" ; inverts the PS_ON output for Meanwell power supplies

;; geometry ------------------------------------------------

M669  K1                 	; corexy mode
M208 X0 Y0 Z-3 S1			; S1 = set axes minima
M208 X252 Y260 Z220 S0  	; S0 = set axes maxima


;M557 X20:240 Y25:235 S20    ; configure z probing grid for mesh compensation
M557 X30:240 Y30:235 S25

M98 P"/macros/zprobe/use_mfast.g"
M98 P"/macros/zprobe/use_ifast.g"


;; drive ---------------------------------------------------

;; Motor layout:
;;  E0 E1
;;  YB XA
;;  Z1 Z2
;;  Z0 Z3

M584 X9 Y0 Z5:6:7:8 E3				; motor bindings
;;M574 X2 Y2 Z0 S1        			; endstops

M574 X2 S1 P"xstop"   	; X min active low endstop switch
M574 Y2 S1 P"ystop"   	; Y min active low endstop switch
M574 Z1 S1 P"zstop"   	; Z min active high endstop switch

M671 X-65:-65:315:315 Y-10:325:325:-10 S20	; Z leadscrews positions


M569 P9 S1      ; X motor direction
M569 P0 S1      ; Y motor direction
M569 P5 S0      ; Z-- motor direction
M569 P6 S1      ; Z+- motor direction
M569 P7 S0      ; Z++ motor direction
M569 P8 S1      ; Z++ motor direction
M569 P3 S0      ; E0 motor direction

M84 S3600                           ; motor idle timeout
M906 I50                            ; motor idle current percentage
M350 X16 Y16 Z16 E16 I1             ; set microstepping
M92 X80 Y80 Z400 E682           	; set microsteps per mm

M569 P0 F8        ; set Stepper idle Noise for X
M569 P1 F8        ; set Stepper idle Noise for Y
M569 P3 F8        ; set Stepper idle Noise for E 

;; velocity, acceleration, and current settings are in these macros
M98 P"/macros/drive/xy_fullcurrent.g"
M98 P"/macros/drive/z_fullcurrent.g"
M98 P"/macros/drive/e_fullcurrent.g"


;; firmware retraction -------------------------------------

;; Choose one as your default:
;; M98 P"/macros/retraction/quiet_nozhop.g
;M98 P"/macros/retraction/quiet_zhop.g
;M98 P"/macros/retraction/pa_nozhop.g"
;M98 P"/macros/retraction/pa_zhop.g"

;; thermal -------------------------------------------------

;Bed
M308 S0 P"bedtemp" Y"thermistor" R4700 T100000 B3950 A"Bed Pad"   	; configure sensor 0 as thermistor on pin bedtemp (pad sensor)
M308 S4 P"e2temp" Y"thermistor" T100000 B3950 A"Bed Plate"  	; configure sensor 2 as thermistor on pin e1temp (plate sensor)
M950 H0 C"bedheat" T4                                  	; create bed heater output on out0 and map it to sensor 2 (plate sensor). Set PWM frequency to 10Hz
M307 H0 B1 S0.8                                             	; Enable Bang Bang mode and set PWM to 50% to avoid warping
M140 P0 H0                                                  	; Mark heater H0 as bed heater (for DWC)
;M143 H0 P0 T0 S110 A2 C0                                    	; Regulate (A2) bed heater (H0) to have pad sensor (T0) below 110°C. Use Heater monitor 1 for it
M143 H0 P2 T0 A2 S130 C0                                    	; Shut off (A1) bed heater (H0) if pad sensor (T0) exceeds 120°C. Use Heater monitor 2 for it
M143 H0 P0 T0 A3 S135 C0                                    	; Regulate (A2) bed heater (H0) to have pad sensor (T0) below 110°C. Use Heater monitor 1 for it
M143 H0 P1 T0 A3 S130 C0										; shutt off printer when Pad ist above 130°C
M143 H0 P1 T4 A3 S130 C0										; shutt off printer when Pad ist above 130°C
M143 H0 S120                                                	; Set bed heater max temperature to 120°C, use implict monitor 0 which is implicitly configured for heater fault
M307 H0 B1 S0.6                                             	; Enable Bang Bang mode and set PWM to 60% to avoid warping
M570 H0 P10 T15 S0

;HotEnd
;M308 S1 P"e0temp" Y"pt1000" B4700 C7.060000e-8 A"Hotend"  	 	; configure sensor 1 as thermistor
M308 S1 P"e0temp" Y"thermistor" B4725 C7.060000e-8 A"Hotend"    	; configure sensor 1 as thermistor
M950 H1 C"!exp.heater7" T1                          					; create nozzle heater output on e0heat and map it to sensor 1
M143 H1 S315                                					; set temperature limit for heater 1 to 275C
;M307 H1 B0 S1.00                               				; disable bang-bang mode for the nozzle heater and set PWM limit
M143 H1 P0 S300 A3
M570 H1 P4 T10 S0 

;Chamber 
M308 S2 P"e1temp" Y"thermistor" R4700 T100000 B4138 A"Chamber"		;Chamber fan
M950 H2 C"!exp.heater4" T2											;Chamber Assigned to unused Heater port to show on front page
M141 H2																;Assign as chamber heater

;Board
M308 S3 Y"mcu-temp" A"Board"

;; M303 H1 S235 ; run autotune
;; M500 to save autotune results to config-override.g,
;; then move the heater config lines from config-override.g here.
;; (Delete them from config-override.g, or you will be confused when changing this file doesn't work.)

;PID Settings
M307 H2 B1 S0.01 V23.7							;PID for chamber set to reduce chance of faults with no heater
M307 H0 A301.0 C845.3 D1.4 S1.00 V23.6 B0		
;M307 H1 A482.6 C291.7 D5.5 S1.00 V23.6 B0 ;V6
M307 H1 A395.7 C171.7 D2.3 S1.00 V23.6 B0 ; Mosquito w/ sock

;Misc
M912 P0 S-8 ;MCU tempurature sensor correction


;; fans -------------------------------------------------
;Part Fan
M950 F0 C"fan2" Q40
M106 P0 S0                   ; part fan

;Hot End
M950 F1 C"fan0" 
M106 P1 H1 T80 S255     ; hotend fan PWMED DOWN



;; tools ---------------------------------------------------

M563 P0 D0 H1       ; bind tool 0 to drive and heater
G10 P0 X0 Y0 Z0     ; tool offset
G10 P0 S0 R0        ; tool active and standby temp

T0                  ; activate tool 0


;; filament sensor ---------------------------------------
;M591 D0 P3 C3 S0 R75:125 L24.8 E3.0 ; Duet3D rotating magnet sensor for extruder drive 0 is connected to E0 endstop input, enabled, sensitivity 24.8mm.rev, 85% to 115% tolerance, 3mm detection length


;; led Lighting---------------------------------------------------
M950 P4 C"e1heat" Q500	;use heater 1 outupt for LED




;; external Trigger
M581 T3 C0 I"e0stop"                   ;Trigger 3 on Endstop E0      (Move Up 50mm)
M581 T4 C0 S1 I"duex.e2stop"           ;Trigger 4 on duex2endstop    (Move Down 50mm)
M581 T5 C0 I"e1stop"                   ;Trigger 5 on Endstop E1      (Heated Bed On/Off)
M581 T8 C0 S1 I"duex.e3stop"           ;Trigger 8 on duex3endstop    (G28)
M581 T9 C0 S1 I"duex.e4stop"           ;Trigger 9 on duex4endstop    (G32)


M501