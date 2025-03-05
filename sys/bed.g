;; ========================================================================
;; Bed Leveling and Gantry Alignment Macro
;; For Voron 2.4 Printer
;; ========================================================================

;; -------------------------
;; Initial Setup
;; -------------------------
M561 ; Clear bed transform before final Z-height adjustment

;; -------------------------
;; Quick Bed Leveling
;; -------------------------
M561 ; Clear bed transform again before starting leveling process

G90 ; Switch to absolute positioning mode
G0 X220 Y200 Z25 F99999 ; Move nozzle to back-left corner
M98 P"/macros/homing/scripts/probe_zi.g" ; Perform initial Z-axis probing

;; ========================================================================
;; Multi-Stage Probing Process
;; ========================================================================

;; -------------------------
;; Fast Probing Stage (30mm/s)
;; -------------------------
M98 P"/macros/zprobe/use_ifast30.g"
M558 K0 H10 F1200 ; Configure fast probing parameters
M98 P"/macros/homing/scripts/probe_zlevel.g"

;; -------------------------
;; Medium-Speed Probing Stage
;; -------------------------
M98 P"/macros/zprobe/use_islow.g"
M558 K0 H4 F240 ; Configure medium-speed probing parameters
M98 P"/macros/homing/scripts/probe_zlevel.g"

;; -------------------------
;; Final Slow Probing Stage
;; -------------------------
M558 K0 H1 F60 ; Configure final slow probing parameters
M98 P"/macros/homing/scripts/probe_zlevel.g"
M98 P"/macros/homing/scripts/probe_zlevel.g"
M98 P"/macros/homing/scripts/probe_zlevel.g"

;; Restore Default Probe Settings
M98 P"/macros/zprobe/use_ifast.g"

;; ========================================================================
;; Final Z-Height Adjustment
;; ========================================================================
M561 ; Clear bed transform before final adjustment
;; M98 P"/macros/moveto/get_probe/end_mesh.g"
G28  ; Perform final Z-axis homing
G1 Z30 F1000