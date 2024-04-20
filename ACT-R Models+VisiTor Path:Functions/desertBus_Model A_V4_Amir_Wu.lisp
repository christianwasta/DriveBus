
;;
;; Siyu Wu 20230312, contributors: Frank Ritter, Amirreza Bagherzadehkhorasani, please add your name here after you help with the model
;; Amir, this model still needs your help with writing defun whereis. Now when run the model it shows the whereis function didn't get defined
;; Amir: Of course it is giving you this error! You first need to define a function in lisp and call python through that. Then it will start to find what you are looking for
;; Siyu: seperate the move-attetnion-go into two production rules, first move attention then second go.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Model A description, calculates difference btween two points
;; Please see
;; https://pennstateoffice365-my.sharepoint.com/:p:/r/personal/sfw5621_psu_edu/Documents/DriveBus_2023/DrivingBus_HCAI_02132023%202%202.pptx?d=w879488a9d68a4a84bef44f6b8;;1b04fce&csf=1&web=1&e=cvd1mL
;; Presentaion slides13,14 for how this model run.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; I. Set up
;;   1. set up global variables
;;   2. load libraries and set up load paths
;;   3. helper functions
;; II. ACT-R model
;;;  1. DMs
;;;  2. start model definiation
;;;  3. Procedural knowledge (get the bus running)
;;;     Control knowledge (how to maintain on the road)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; I. set up (setup for what?(fer))

;; I.a  global variablles

;; define pattern variables

(defvar *mouse-pos* (vector 0 0))
;;
(defvar pattern "")
;; fill in
(defvar *pattern-global* "")
(defvar keyString "")
(defvar command "")
(defvar input1 "")
(defvar input2 "")

;;Visual list
(defvar visual-list '())
;;visual-location ready
;;                Define your own visual object list
(push '(drivingCueTest (2 2)) visual-list)
;;visual-location start
(push '(DrivingCueDanger (10 10)) visual-list)
;;visual-location danger

;; I.b  load paths and load libraries

;; Define File address variables

;; The directory (address, directory, and direc, why not choose one?)
;;To make sure everything goes smoothly, use windows. Mac is a little bit unreliable in interations
(defvar pythonaddress "C:\\Users\\sfw5621\\Desktop\\VisiTor-main\\VisiTor.py")

(defvar Direc "C:\\Users\\sfw5621\\Desktop\\VisiTor-main\\files")

;; load libraries
(ql:quickload 'inferior-shell)
(ql:quickload "split-sequence")
(require "split-sequence")
;; I.c Helper functions
;;
;;; Start up the simulation (emacs lisp commands)
;;;
(defmethod call-ShellCommand (command &optional arglist)
  (defvar shell-request-list nil "List of shell commands to execute")
  (setq shell-request-list '())
  (setq shell-request-list
    (append shell-request-list
      '("python")
      (list (symbol-value 'pythonaddress))
      (list (symbol-value 'command))
      '("--Dir")
      (list (symbol-value 'Direc))
      '("--arg2")
      arglist))
  (inferior-shell:run/ss shell-request-list))

(defun what-is-on-screen (s)
  "Match or MisMatch for screen s"
  ;; put these two variables into a let to make them local to this function only-fer
  ;; take out of let if you need them to be persitane for debugging
  (let ((command nil)
        (on-screen nil))
  (setf command "whatisonscreen")
  (setq on-screen (call-ShellCommand command s))
;	(setf on-screen "tail")
  (act-r-output "what is on screen function ~A!!!" on-screen)
  on-screen))

(defun set-pattern (p)
  (setf *pattern-global* p)
;  (print "done!")
  (act-r-output " Now we have pattern: ~s !!!!" *pattern-global*)
)

(defun respond-to-move-cursor (x y z)
  ;; what are x, y, z?
  (setf command "movecursortopattern")
  (act-r-output "move-cursor to ~A!!!" z)
  (act-r-output "first element ~A!!!" (nth 0 z))
  ;(print (get-key visual-list (list (nth 0 z)(nth 1 z))))
  ;list output
  (act-r-output "Find in list move-cursor to ~a~%!!!" (get-key visual-list (list (nth 0 z)(nth 1 z))))
  (setq (call-ShellCommand command (list (get-key visual-list (list (nth 0 z)(nth 1 z))))))
)


(defun split-string-by-comma (string)
  (split-sequence:split-sequence #\, string))
(defun strip-spaces-and-parentheses (string)
  (remove-if (lambda (char) (or (char= char #\space)
                                (char= char #\()
                                (char= char #\))))
  string))


; (defun where-is (s)
;   (setf command "whereis")
;  (multiple-value-bind (x y) (split-string-by-comma (strip-spaces-and-parentheses (call-ShellCommand command s))))
;   (act-r-output "finding pattern")
;   (values x y))
(defun where-is (s)
  (setf command "whereis")
  (multiple-value-bind (x y)
      (mapcar #'parse-integer
              (split-string-by-comma
               (strip-spaces-and-parentheses
                (call-ShellCommand command s))))
    (values x y))
    )
(defun longkeypress (x)
  (setf command "continuouspresskey")
  (call-ShellCommand command x)
  (act-r-output "continuouspress a key!"))
  (longkeypress '("x"))

(defun respond-to-click-mouse (x y z)
  ;; what are x, y, z?
  (setf command "click")
  (call-ShellCommand command '("temp")))
;  (setq (call-ShellCommand command '("temp")))
  (act-r-output "click a mouse!")
  (respond-to-click-mouse "temp" "temp" "temp")

(defun get-key (l sublist)
  "Finds a key given the pair of values associated with it"
  ;; l is the list
  ;; sublist if the associted sublist of the key
  ;  (print "working")
  (car (find-if (lambda (parts) (equal sublist (cadr parts))) l)))
  ;; vould be (second parts) -fer


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; II.    Define the ACT-R model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; more substrutor, please
;; read about vanhalen and brown m&m's

(clear-all)

(define-model desertBus

(sgp :seed (10000 100))
(sgp :v t :esc t :lf .05 :trace-detail low :show-focus t :MODEL-WARNINGS NIL :stable-loc-names t :auto-attend t)

(chunk-type drive strategy state item)
(chunk-type encoding a-loc b-loc deviation)

;;  I. DMs
(define-chunks
  (goer ISA drive state start item blank)
  (start) (perceive) (ahead) (recheck) (choose-strategy)
  (find-danger) (whereis)(whereisnext) (calculate-deviation) (consider-next) (whatisonscreen)
  (blank))

;; Install device
(install-device '("motor" "keyboard"))

;; combine visitor and act-r commands
(add-act-r-command "my-move-attention" 'what-is-on-screen "sth") ;; Good
(monitor-act-r-command "move-attention" "my-move-attention") ;; Good
(add-act-r-command "my-keyhold" 'longkeypress  "sth")  ;;Define it ; Siyu: done
(monitor-act-r-command "output-key" "my-keyhold") ;;Good
(add-act-r-command "my-whereis" 'whereis "sth")  ;;Define it
  (monitor-act-r-command "start-tracking" "my-whereis") ;;Good
  (start-hand-at-key 'right "w")  ;;Amir: Really uncomfortable posture!!
  (add-visicon-features '(screen-x 2 screen-y 2 value drivingCueTest))
  (add-visicon-features '(screen-x 10 screen-y 10 value DrivingCueDanger))


;;Put drive into the goal buffer
(goal-focus goer)

;; II. Procedural knowledge (get the bus running)
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

;; look around the environement to see if the driving Cue exists,
(p perceive-environment
   =goal>
      ISA         drive
      state       perceive
 ==>
     ;?visual-location>
     ;  ISA         visual-location
     ; :attended   nil
   =goal>
      state       move-attention
      item        "drivingCueTest"
      )


;;if drivingCue is found, go ahead, w is accelerate
  ;;Divide rule into two different production rules. You first find the cue and then press the key. They don't happen at the same time... Or maybe you think they will. If so, I'm fine with it.
  ;;Siyu: agree, done
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

;;control production
;;recheck the environment and move attention to the DrivingCueDanger
;; like this one. This production rule runs at the same time as the previous one is using motor module which is good IMO.
(p recheck-environment
   =goal>
      ISA         drive
      state       recheck
   =visual-location>
      value      drivingCueTest
==>
    ; +visual-location>
    ; buffer     empty
   =goal>
       state      choose-strategy)

(p danger
   =goal>
      ISA        drive
      state      choose-strategy
   ?visual>
      state      free
==>
   =goal>
      item       "DrivingCueDanger"
      state      find-danger)

(p finding-danger
   =goal>
      ISA        drive
      state      find-danger
      item       "DrivingCueDanger"
==>
   +visual-location>
      ISA        visual-location
      value      DrivingCueDanger
   =goal>
      state      move-attention
      item       "DrivingCueDanger")

(p move-attention-danger
   =goal>
      ISA       drive
      state     move-attention
      item      "DrivingCueDanger"
   =visual-location>
      value     DrivingCueDanger
   ?visual>
      state     free
==>
      +visual>
      ISA       move-attention
      screen-pos =visual-location
    =goal>
      state     whereis)

;;get the x-axis location of DrivingCueDanger
(p whereisDanger
   =goal>
      ISA       drive
      state     whereis
  ?imaginal>
      buffer    empty
      state     free
==>
      !mv-bind! (=a  =b) (first (where-is '("DrivingCueDanger")))
;      !output! (=a)

   =goal>
      state    whereisnext
   +imaginal>
       isa      encoding
       a-loc   =a)

;;get the x-axis location of center yellow dash.
;; Amir: Don't we need to declare that the b-loc value is nil in the definiiton of the encoding to make sure the default value is nil?
;; Amir: I'm not sure though. But I suggest checking it
(p whereisCenter
   =goal>
      ISA      drive
      state    whereisnext
   =imaginal>
      isa     encoding
      a-loc   =a
      b-loc   nil
==>
      !mv-bind! (=c  =d) (first (where-is'("drivingCueTest")))
   =goal>
      state   calculate-deviation
      +imaginal>
         isa     encoding
         a-loc   =a
         b-loc   =c)

;; caculate the difference between the two x-axis locations
(p calculate-deviation
  =goal>
   isa  drive
   state calculate-deviation
  =imaginal>
   a-loc   =a
   b-loc   =c
  ?visual>
   state free
==>
   !bind! =val(- =a =c)
=imaginal>
   deviation =val
   =goal>
   state   consider-next)

;; if difference smaller and equal to 800 pixcel, keep ahead,then loop to perceive the environment
(p consider-ahead
 =goal>
   isa  drive
   state consider-next
=imaginal>
   isa encoding
   <= deviation 200
   ?visual>
   state  free
   ?manual>
   state  free
 ==>
!eval! (longkeypress '("w"))
   +manual>
      ISA         punch
      hand        right
      finger      index
   =goal>
   state       perceive
   +visual-location>
   )

;; if difference larger than 800 pixcel, steer left, then loop to perceive the environment
(p consider-steer
=goal>
   isa  drive
   state consider-next
=imaginal>
   isa encoding
   > deviation 200
   ?visual>
   state  free
   ?manual>
   state  free
 ==>
!eval! (longkeypress '("a"))
   +manual>
      ISA        punch
      hand      right
      finger    index
     
   =goal>
   state       perceive
   +visual-location>
   )

)
;;Amir: Overall, great code. You have made some huge progress! I'm impressed.
