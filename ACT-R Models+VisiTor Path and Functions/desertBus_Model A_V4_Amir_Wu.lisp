(ql:quickload 'inferior-shell)
(use-package 'inferior-shell)
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
(defvar pythonaddress "C:\\Users\\seanw\\OneDrive\\Desktop\\Drivebus\\VisiTor-main\\VisiTor.py")

(defvar Direc "C:\\Users\\seanw\\OneDrive\\Desktop\\Drivebus\\VisiTor-main\\")

;; load libraries
(ql:quickload 'inferior-shell)
(ql:quickload "split-sequence")
(require "split-sequence")
;; I.c Helper functions
;;
;;; Start up the simulation (emacs lisp commands)
;;;
(defvar shell-request-list nil "List of shell commands to execute")
(defmethod call-ShellCommand (command &optional arglist)
  (let* ((python-path "C:\\Users\\seanw\\AppData\\Local\\Microsoft\\WindowsApps\\python.exe")
         (full-command (list python-path
                             (symbol-value 'pythonaddress)
                             command
                             "--Dir"
                             (symbol-value 'Direc)
                             "--arg2"))
         (full-command (append full-command (if (listp arglist) arglist (list arglist)))))
    (format t "Executing command: ~S~%" full-command)
    (multiple-value-bind (output error-output exit-code)
        (uiop:run-program full-command :output :string :error-output :string :ignore-error-status t)
      (format t "Python script output:~%~a~%" output)
      (format t "Python script error output:~%~a~%" error-output)
      (format t "Python script exit code: ~a~%" exit-code)
      (if (= exit-code 0)
          output
          (error "Python script exited with error code ~a. Output: ~a Error: ~a" 
                 exit-code output error-output)))))
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
(defun get-key (l sublist)
  "Finds a key given the pair of values associated with it"
  ;; l is the list
  ;; sublist if the associted sublist of the key
  ;  (print "working")
  (car (find-if (lambda (parts) (equal sublist (cadr parts))) l)))
  ;; vould be (second parts) -fer


(defun respond-to-move-cursor (z)
  ;; what are x, y, z?
  (setf command "movecursortopattern")
  (act-r-output "move-cursor to ~A!!!" z)
  (act-r-output "first element ~A!!!" (nth 0 z))
  ;(print (get-key visual-list (list (nth 0 z)(nth 1 z))))
  ;list output
  (act-r-output "Find in list move-cursor to ~a~%!!!" (get-key visual-list (list (nth 0 z)(nth 1 z))))
  (call-ShellCommand command (list (get-key visual-list (list (nth 0 z)(nth 1 z)))))
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
  (let* ((output (call-ShellCommand command s))
         (lines (split-sequence:split-sequence #\Newline output))
         (result-line (find "RESULT:" lines :test #'search))
         (coords (when result-line 
                   (read-from-string 
                    (subseq result-line (+ (search "RESULT:" result-line) 7))))))
    (if (and (listp coords) (= (length coords) 2))
        (values (first coords) (second coords))
        (progn
          (print (format nil "Error parsing whereis output: ~A" output))
          (values nil nil)))))

(defun longkeypress (key)
  (setf command "continuouspresskey")
  (call-ShellCommand command (list key))
  (act-r-output "continuwouspress a key! ~A" key))

(defun shortkeypress (key)
  (setf command "shortkeypress")
  (call-ShellCommand command (list key))
  (act-r-output "short key press of a key! ~A" key))

(defun my-short-keypress (model key)
  (declare (ignore model))
  (shortkeypress key))

(defun my-keyhold (model key)
  (declare (ignore model))
  (longkeypress key))

(defun respond-to-click-mouse ()
  ;; what are x, y, z?
  (setf command "click")
  (call-ShellCommand command '("temp")))
;  (setq (call-ShellCommand command '("temp")))
  (act-r-output "click a mouse!")
  ;(respond-to-click-mouse)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; II.    Define the ACT-R model
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; more substrutor, please
;; read about vanhalen and brown m&m's

(clear-all)
(print-visicon)
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
(add-act-r-command "my-keyhold" 'my-keyhold "Keypress command")
(add-act-r-command "my-short-keypress" 'my-short-keypress "Short keypress command")
(monitor-act-r-command "output-key" "my-short-keypress")
(monitor-act-r-command "output-key" "my-keyhold") ;;Good
(add-act-r-command "my-whereis" 'whereis "sth")  ;;Define it
  (monitor-act-r-command "start-tracking" "my-whereis") ;;Good
  (start-hand-at-key 'right "w")  ;;Amir: Really uncomfortable posture!!
  (add-visicon-features '(screen-x 10 screen-y 10 value DrivingCueDanger))
  (add-visicon-features '(screen-x 2 screen-y 2 value drivingCueTest))
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
   !eval! (progn
            (model-output "Visicon contents:")
            (print-visicon))
   =goal>
      state       move-attention
      item        "drivingCueTest"
   +visual-location>
      ISA         visual-location
   !output! ("Perceiving environment")
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
 !eval! (longkeypress "w")
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
    +visual-location>  ; Request a new visual location
    =goal>
       state      choose-strategy
    !output! ("Rechecking environment")
)

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
(p whereisdanger
   =goal>
      ISA       drive
      state     whereis
   ?imaginal>
      state     free
==>
   !mv-bind! (=a =b) (where-is '("DrivingCueDanger"))
   !output! ("WHERE-IS returned: ~S ~S" =a =b)
   =goal>
      state    whereisnext
   +imaginal>
      isa      encoding
      danger-x =a
      danger-y =b
)

(p whereiscenter
   =goal>
      ISA      drive
      state    whereisnext
   =imaginal>
      isa     encoding
      danger-x =a
      danger-y =b
==>
   !mv-bind! (=c =d) (where-is '("drivingCueTest"))
   =goal>
      state   calculate-deviation
   =imaginal>
      isa     encoding
      danger-x =a
      danger-y =b
      center-x =c
      center-y =d
)

(p calculate-deviation
  =goal>
   isa  drive
   state calculate-deviation
  =imaginal>
   danger-x =a
   center-x =c
==>
   !bind! =val (- =c =a)
   =imaginal>
      isa      encoding
      deviation =val
   =goal>
      state   consider-next
   !output! ("Calculated deviation: ~D" =val)
)

(p handle-missing-cue
 =goal>
   isa  drive
   state consider-next
 =imaginal>
   isa encoding
   danger-x -1
   center-x -1
==>
 !eval! (longkeypress "w")
 =goal>
   state  perceive
 +visual-location>
   isa  visual-location
 !output! ("Both cues missing, moving forward")
)

(p consider-ahead
 =goal>
   isa  drive
   state consider-next
 =imaginal>
   isa encoding
   danger-x =a
   center-x =c
   deviation =dev
==>
 !eval! (cond ((= =a -1) (longkeypress "w"))
              ((= =c -1) (my-short-keypress nil "a"))
              ((> =dev 300) (my-short-keypress nil "a"))
              (t (longkeypress "w")))
 !eval! (longkeypress "w")             
 =goal>
   state  perceive
 +visual-location>
   isa  visual-location
 !output! ("Decision made: ~A, deviation: ~D" 
           (cond ((= =a -1) "move forward (left cue missing)")
                 ((= =c -1) "steer left (right cue missing)")
                 ((> =dev 300) "steer left")
                 (t "move forward"))
           =dev)
)

(p choose-steer
 =goal>
   isa  drive
   state choose-steer
 ?manual>
   state  free
==>
 !eval! (my-short-keypress "a")
 =goal>
   state  perceive
 +visual-location>
   isa  visual-location
 !output! ("Steering left by pressing 'a'")
)

(p continue-cycle
   =goal>
      ISA         drive
      state       perceive
==>
   =goal>
      state       choose-strategy
   !output!       ("Continuing cycle - choosing new strategy")
)
)
;;Amir: Overall, great code. You have made some huge progress! I'm impressed.
