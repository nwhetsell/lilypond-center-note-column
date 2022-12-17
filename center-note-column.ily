\version "2.16.0"

#(define (sort-by-X-coord sys grob-lst)
"Arranges a list of grobs in ascending order by their X-coordinates"
   (let* ((X-coord (lambda (x) (ly:grob-relative-coordinate x sys X)))
          (comparator (lambda (p q) (< (X-coord p) (X-coord q)))))

     (sort grob-lst comparator)))

#(define (find-bounding-grobs note-column grob-lst)
   (let* ((sys (ly:grob-system note-column))
          (X-coord (lambda (n) (ly:grob-relative-coordinate n sys X)))
          (note-column-X (X-coord note-column)))

      (define (helper lst)
        (if (and (< (X-coord (car lst)) note-column-X)
                 (> (X-coord (cadr lst)) note-column-X))
            (cons (car lst) (cadr lst))
            (if (null? (cddr lst))
                (cons note-column note-column)
                (helper (cdr lst)))))

      (helper grob-lst)))

#(define (read-out ls1 ls2 ls3 symbol)
"Filters all elements of ls1 from ls2 and appends it to ls3"
(set! ls3 (append ls3 (filter (lambda (x) (eq? (car ls1) (symbol x))) ls2)))
  (if (null? (cdr ls1))
      ls3
      (read-out (cdr ls1) ls2 ls3 symbol)))

#(define ((center-note-column x-offs) grob)
     (let* ((sys (ly:grob-system grob))
            (elements-lst (ly:grob-array->list (ly:grob-object sys 'all-elements)))
            (grob-name (lambda (x) (assq-ref (ly:grob-property x 'meta) 'name)))
            (X-extent (lambda (q) (ly:grob-extent q sys X)))
      ;; NoteColumn
            (note-column-coord (ly:grob-relative-coordinate grob sys X))
            (grob-ext (X-extent grob))
            (grob-length (interval-length grob-ext))
      ;; NoteHeads
            (note-heads (ly:grob-object grob 'note-heads))
            (note-heads-grobs (if (not (null? note-heads))
                         (ly:grob-array->list note-heads)
                         '()))
            (one-note-head (if (not (null? note-heads-grobs))
                        (car note-heads-grobs)
                        '()))
            (one-note-head-length (if (not (null? one-note-head))
                             (interval-length (X-extent one-note-head)) ;; NB
                             0))
      ;; Stem
            (stem (ly:grob-object grob 'stem))
            (stem-dir (ly:grob-property stem 'direction))
            (stem-length-x (interval-length (X-extent stem))) ;; NB
      ;; DotColumn
            (dot-column (ly:note-column-dot-column grob))
      ;; AccidentalPlacement
            (accidental-placement (ly:note-column-accidentals grob))
      ;; Arpeggio
            (arpeggio (ly:grob-object grob 'arpeggio))
      ;; Rest
            (rest (ly:grob-object grob 'rest))
      ;; Grobs to center between
            (args (list 'BarLine
                        'Clef
                        'KeySignature
                        'KeyCancellation
                        'TimeSignature))
            (grob-lst (read-out args elements-lst '() grob-name))
            (new-grob-lst (remove (lambda (x) (interval-empty? (X-extent x))) grob-lst))
            (sorted-grob-lst (sort-by-X-coord sys new-grob-lst))
      ;; Bounds
            (bounds (find-bounding-grobs grob sorted-grob-lst))
            (left (cdr (X-extent (car bounds))))
            (right (car (X-extent (cdr bounds))))

            (basic-offset
              (- (average left right)
                 (interval-center (X-extent grob))
                 (* -1 x-offs)))
            (dir-correction
              (if (> grob-length one-note-head-length)
                  (* stem-dir (* -2 stem-length-x) grob-length)
                  0))

            ) ;; End of Defs in let*

   ;; Calculation
   (begin
     (for-each
       (lambda (x)
         (cond ((ly:grob? x)
          (ly:grob-translate-axis!
            x
            (- basic-offset dir-correction)
            X))))
        (list
          (cond ((not (null? note-heads)) grob))
          dot-column accidental-placement arpeggio rest))
  )))

#(ly:expect-warning "deprecated: missing `.' in property path Staff.NoteColumn.after-line-breaking")
#(define centerNoteColumnOn #{ \override Staff.NoteColumn #'after-line-breaking = #(center-note-column 0) #})

#(ly:expect-warning "deprecated: missing `.' in property path NoteColumn.after-line-breaking")
#(define centerNoteColumnOff #{ \revert Staff.NoteColumn #'after-line-breaking #})

#(define onceCenterNoteColumn (define-music-function (parser location x-offs)(number?)
#{
        #(ly:expect-warning "deprecated: missing `.' in property path Staff.NoteColumn.after-line-breaking")
        \once \override Staff.NoteColumn #'after-line-breaking = #(center-note-column x-offs)
#}))
