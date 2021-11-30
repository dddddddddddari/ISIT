;;****************
;;* DEFFUNCTIONS *
;;****************

(deffunction ask-question (?question $?allowed-values)
   (printout t ?question)
   (bind ?answer (read))
   (if (lexemep ?answer) 
       then (bind ?answer (lowcase ?answer)))
   (while (not (member$ ?answer ?allowed-values)) do
      (printout t ?question)
      (bind ?answer (read))
      (if (lexemep ?answer) 
          then (bind ?answer (lowcase ?answer))))
   ?answer)

(deffunction yes-or-no-p (?question)
   (bind ?response (ask-question ?question yes no y n))
   (if (or (eq ?response yes) (eq ?response y))
       then yes 
       else no))

;;;***************
;;;* QUERY RULES *
;;;***************

(defrule determine-camera-dropped ""
   (not (camera-dropped ?))
   (not (problem ?))
   =>
   (assert (camera-dropped (yes-or-no-p "Has the camera been dropped? (yes/no)? "))))
   
(defrule determine-visible-damage ""
   (not (visible-damage ?))
   (not (problem ?))
   =>
   (assert (visible-damage (yes-or-no-p "Is there any visible damage? (yes/no)? "))))

(defrule determine-prev-film ""
   (not (prev-film ?))
   (not (problem ?))
   =>
   (assert (prev-film (yes-or-no-p "Had problems with the previous film? (yes/no)? "))))

(defrule determine-rewind-but ""
   (not (rewind-but ?))
   (not (problem ?))
   =>
   (assert (rewind-but (yes-or-no-p "Is the rewind button stable? (yes/no)? "))))

(defrule determine-moisture-entered ""
   (not (moisture-entered ?))
   (not (problem ?))
   =>
   (assert (moisture-entered (yes-or-no-p "Could moisture get in? (yes/no)? "))))

(defrule determine-shelf-life ""
   (not (shelf-life ?))
   (not (problem ?))
   =>
   (assert (shelf-life (yes-or-no-p "Has the film expired? (yes/no)? "))))

(defrule determine-light-hit ""
   (not (light-hit ?))
   (not (problem ?))
   =>
   (assert (light-hit (yes-or-no-p "Could light have hit the film? (yes/no)? "))))

(defrule determine-curtains-stably ""
   (not (curtains-stably ?))
   (not (problem ?))
   =>
   (assert (curtains-stably (yes-or-no-p "Do the curtains work stably? (yes/no)? "))))



(defrule mechanical-defect-yes ""
   (and (camera-dropped yes)      
        (visible-damage yes))
   (not (problem ?))
   =>
   (assert (mechanical-defect yes)))

(defrule mechanical-defect-no ""
   (and (camera-dropped no)      
        (visible-damage no))
   (not (problem ?))
   =>
   (assert (mechanical-defect no)))

(defrule curtains-broken-yes ""
   (and (mechanical-defect yes)      
        (curtains-stably no))
   (not (problem ?))
   =>
   (assert (curtains-broken yes)))

(defrule curtains-broken-no ""
   (and (mechanical-defect yes)      
        (curtains-stably yes))
   (not (problem ?))
   =>
   (assert (curtains-broken no)))

(defrule rewind-broken-yes ""
   (and (mechanical-defect yes)      
        (rewind-but no))
   (not (problem ?))
   =>
   (assert (rewind-broken yes)))

(defrule rewind-broken-no ""
   (and (mechanical-defect yes)      
        (rewind-but yes))
   (not (problem ?))
   =>
   (assert (rewind-broken no)))

(defrule film-problem-yes ""
   (and (mechanical-defect no)      
        (prev-film no))
   (not (problem ?))
   =>
   (assert (film-problem yes)))

(defrule film-problem-no ""
   (and (shelf-life no)      
        (light-hit no)
	(moisture-entered no))
   (not (problem ?))
   =>
   (assert (film-problem no)))

(defrule film-light-yes ""
   (and (film-problem yes)      
        (light-hit yes))
   (not (problem ?))
   =>
   (assert (film-light yes)))

(defrule film-light-no ""    
   (light-hit no)
   (not (problem ?))
   =>
   (assert (film-light no)))

;;;****************
;;;* PROBLEM RULES *
;;;****************

(defrule camera-repair-curt ""
   (and (prev-film yes)     
        (curtains-broken yes))
   (not (problem ?))
   =>
   (assert (problem "The curtains are broken. Contact service.")))

(defrule camera-repair-rew ""
   (and (prev-film yes)     
        (rewind-broken yes))
   (not (problem ?))
   =>
   (assert (problem "The rewind button is broken.Contact service.")))

(defrule unknown-damage ""
(or (and (film-problem no)
    	 (mechanical-defect no))
    (and (rewind-broken no)     
         (curtains-broken no)))
   (not (problem ?))
   =>
   (assert (problem "Most likely the camera is faulty")))

(defrule new-film ""
(and (mechanical-defect no)
   (or (shelf-life yes)     
       (film-light yes)
       (moisture-entered yes)))
   (not (problem ?))
   =>
   (assert (problem "Use new film.")))    

(defrule no-problem ""
  (declare (salience -10))
  (not (problem ?))
  =>
  (assert (problem "Try again!!! I couldn't find the problem")))

;;;********************************
;;;* STARTUP AND CONCLUSION RULES *
;;;********************************

(defrule system-banner ""
  (declare (salience 10))
  =>
  (printout t crlf crlf)
  (printout t "Film camera diagnostics")
  (printout t crlf crlf))

(defrule print-problem ""
  (declare (salience 10))
  (problem ?item)
  =>
  (printout t crlf crlf)
  (printout t "Suggested problem:")
  (printout t crlf crlf)
  (format t " %s%n%n%n" ?item))