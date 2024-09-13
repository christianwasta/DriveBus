;;
;; Driving Bus Model
;;
;; Siyu Wu 20230304, contributors: Frank Ritter, Amirreza Bagherzadehkhorasani, please add your name here after you help with the model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Model description
;; Please see
;; https://pennstateoffice365-my.sharepoint.com/:p:/r/personal/sfw5621_psu_edu/Documents/DriveBus_2023/DrivingBus_HCAI_02132023%202%202.pptx?d=w879488a9d68a4a84bef44f6b8;;1b04fce&csf=1&web=1&e=cvd1mL
;; Presentaion slides 15,16 for how this model run.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;I. Set up
;;II. ACT-R model
;;;  1. DMs
;;;  2. start model definiation
;;;  3. Procedural knowledge (get the bus running)
;;;     Control knowledge (how to maintain on the road)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; I. set up (setup for what?(fer))
;; define pattern

(defvar *mouse-pos* (vector 0 0))
(defvar pattern "")
(defvar *pattern-global* "")
(defvar keyString "")
(defvar command "")
(defvar input1 "")
(defvar input2 "")

;;File addresses

;; The directory
(defvar pythonaddress "C:\\Users\\seanw\\OneDrive\\Desktop\\Drivebus\\VisiTor-main\\VisiTor.py")
;;======================================================================
(defvar Direc "C:\\Users\\seanw\\OneDrive\\Desktop\\Drivebus\\VisiTor-main\\")

;;; Start up the simulation (emacs lisp commands)
;;; How to send a command to Python running with us? right? why is this a method
;;; and not a function?(fer)
(ql:quickload 'inferior-shell)
(defmethod call-ShellCommand (command &optional arglist)
  (setq shell-request-list '())
  ;(print shell-request-list)
  ;(print "new list ")
  (setq shell-request-list
    (append shell-request-list
      '("python")
      (list (symbol-value 'pythonaddress))
      (list (symbol-value 'command))
    '("--Dir")
    (list (symbol-value 'Direc)) '("--arg2") arglist
  ))
  ; (print shell-request-list)
  (inferior-shell:run/ss shell-request-list )
  )

(defun what-is-on-screen (l)
  "Match or MisMatch for screen l"
  (setf command "whatisonscreen")
  (setq on-screen (call-ShellCommand command l))
;	(setf on-screen "tail")
  (act-r-output "what is on screen function ~A!!!" on-screen)
  on-screen)

(defun set-pattern (p)
  (setf *pattern-global* p)
;  (print "done!")
  (act-r-output " Now we have ~s !!!!" *pattern-global*)
)

(defun respond-to-move-cursor (x y z)
  (setf command "movecursortopattern")
  (act-r-output "move-cursor to ~A!!!" z)
  (act-r-output "first element ~A!!!" (nth 0 z))
;(print (get-key visual-list (list (nth 0 z)(nth 1 z))))
;list output
  (act-r-output "Find in list move-cursor to ~a~%!!!" (get-key visual-list (list (nth 0 z)(nth 1 z))))
  (setq (call-ShellCommand command (list (get-key visual-list (list (nth 0 z)(nth 1 z))))))
)

(defun respond-to-click-mouse (x y z)
  (setf command "click")
  (call-ShellCommand command '("temp")))
;  (setq (call-ShellCommand command '("temp")))
(act-r-output "click a mouse!")
(respond-to-click-mouse "temp" "temp" "temp")

(defun longkeypress (x)
  (setf command "continuouspresskey")
  (call-ShellCommand command x)
  (act-r-output "continuouspress a key!"))
(longkeypress '("x"))

(defun get-key (l sublist)
  "Finds a key given the pair of values associated with it"
  ;;l is the list
  ;;sublist if the associted sublist of the key
;  (print "working")
  (car (find-if (lambda (parts) (equal sublist (cadr parts))) l)))
;;Visual list
(defvar visual-list '())
;;visual-location ready
;;                Define your own visual object list
(push '(DrivingCueTest (0 0)) visual-list)
;;visual-location start
(push '(DetectCue(10 10)) visual-list)
;;visual-location danger
;(push '(head (20 20)) visual-list)
;(inferior-shell:run ("python" "/Users/SiyuWu/Desktop/VisiTor_Mac-main-1/Visitor.py" "click"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;    Define the ACT-R model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(clear-all)

(define-model desertBus

(sgp :seed (10000 100))
(sgp :v t :esc t :lf .05 :trace-detail low :show-focus t :MODEL-WARNINGS NIL :stable-loc-names t :ul t)

(chunk-type drive strategy state item)


;; 1. DMs
(define-chunks
  (goer ISA drive state start item blank)
  (start) (perceive) (recheck)(ahead)(move-strategy) (steer) (whatisonscreen)
  (blank))

;; install device
;; combine visitor and act-r commands
(add-act-r-command "my-move-attention" 'whatisonscreen "sth")
(monitor-act-r-command "move-attention" "my-move-attention")
(add-act-r-command "my-keyhold" 'longkeypress "sth")
(monitor-act-r-command "output-key" "my-keyhold")
;;(add-act-r-command "my-whereis" 'whereis "sth")
;;(monitor-act-r-command "move-attention" "my-whereis")
(install-device '("motor" "keyboard"))
  (start-hand-at-key 'right "w")
  (add-visicon-features '(screen-x 2 screen-y 2 value drivingCueTest))
  (add-visicon-features '(screen-x 600 screen-y 600 color white value DetectCue))

;;Put drive into the goal buffer
(goal-focus goer)

;; 2. Procedural knowledge (get the bus running)
;;;  2.1 Clear the visual-location buffer and get ready for simulation.
  
(p go
   =goal>
      ISA         drive
      state       start
   ?visual-location>
      buffer      unrequested
 ==>
   =goal>
      state       perceive
      !output!    ("Ready to go")
      )

;;;   2.2look around the environement to see if the center driving cue exists

(p perceive-environment
   =goal>
      ISA         drive
      state       perceive
 ==>
 ; ?visual-location>
      ;ISA         visual-location
     ; :attended   nil
   =goal>
      state       move-attention
      item        "drivingCueTest"
      )


;;;   2.3 If drivingCueTest is found, go ahead, w is accelerate
(p move-attention
   =goal>
      ISA       drive
      state     move-attention
      item      "drivingCueTest"
   ?visual>
       state    free
    =visual-location>
       value     drivingCueTest
==>
    +visual>
      ISA         move-attention
      screen-pos  =visual-location
   +visual-location>
       value       drivingCueTest
   =goal>
   state      ahead)

  (p ahead
   =goal>
       ISA       drive
       state      ahead

   ?manual>
       state    free
==>
 !output!   ("hiii")
 !eval! (longkeypress '("w"))
   +manual>
      ISA     punch
      hand    right
      finger  index
   =goal>
        state   recheck)

;;Control center
;;;  2.4 Recheck the environment that if (DetectCue)is exsisted  
(p recheck-environment-cue
   =goal>
      ISA         drive
     state       recheck
   ?visual>
      state        free
   ?manual>
      buffer      empty
   ==>
  
   =goal>
      state      move-strategy
      item       "DetectCue")
  
;;;  2.4 Recheck the environment, if DetectCue is not found
(p recheck-environment-no-cue
   =goal>
    ISA         drive

   state      recheck
   ?visual>
      state        free
   ?manual>
      buffer      empty
 ==>
   =goal>  
      state        move-strategy
   item         "blank"
   +visual-location>
  )
;;;  2.5 when find the DetectCue, harvest visual chunk and steer press A, and then loop back to perceive the environment
(p finding-cue
   =goal>
       ISA        drive
       state     move-strategy
       item      "DetectCue"
  
==>
   =goal>
      state     steer
   +visual-location>
     value    DetectCue)
  

(p steer
    =goal>
      state      steer
      =visual-location>
      value      DetectCue
     ?visual>
      state       free
     ?manual>
      state       free
 ==>
     !eval! (longkeypress '("a"))
   +manual>
      ISA         punch
      hand        right
      finger      index
   =goal>
   state       perceive
   +visual-location>
     )

;;;  2.6 when not find DetectCue,loop back to perceive the environment
(p no-finding-cue
    =goal>
    state     move-strategy
    item      "blank"
      =visual-location> 
     ?visual>
      state     free
     ?manual>
     state      free
==>
    =goal>
     state      perceive
     +visual-location>
   )

  (spp recheck-envirnment-cue :reward 5)
  (spp recheck-environment-no-cue :reward 0)

 )

(defvar visual-list '())
