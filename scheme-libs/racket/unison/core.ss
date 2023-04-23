; This library implements various functions and macros that are used
; internally to the unison scheme libraries. This provides e.g. a
; measure of abstraction for the particular scheme platform. A useful
; feature of one implementation might need to be implemented on top of
; other features of another, and would go in this library.
;
; This library won't be directly imported by the generated unison
; code, so if some function is needed for those, it should be
; re-exported by (unison boot).
#!r6rs
(library (unison core)
  (export
    describe-value
    decode-value

    universal-compare
    chunked-string<?
    universal=?

    fx1-
    list-head

    syntax->list
    raise-syntax-error

    exception->string
    let-marks
    ref-mark

    chunked-string-foldMap-chunks

    freeze-string!
    string-copy!

    freeze-bytevector!
    freeze-vector!

    bytevector)

  (import
    (rnrs)
    (rename (only (racket)
                  string-copy!
                  bytes
                  with-continuation-mark
                  continuation-mark-set-first
                  raise-syntax-error
                  for/fold)
            (string-copy! racket-string-copy!)
            (bytes bytevector))
    (only (srfi :28) format)
    (racket exn)
    (racket unsafe ops)
    (unison data)
    (unison data chunked-seq))

  (define (fx1- n) (fx- n 1))

  (define (list-head l n)
    (let rec ([c l] [m n])
      (cond
        [(eqv? m 0) '()]
        [(null? c) '()]
        [else
          (let ([sub (rec (cdr c) (- m 1))])
            (cons (car c) sub))])))

  ;; TODO support for records
  (define (describe-value x)
    (cond
      [(chunked-string? x)
        (format "\"~a\"" (chunked-string->string x))]
      [(chunked-bytes? x)
       (format
        "0xs~a"
        (chunked-string->string
         (for/fold
           ([acc empty-chunked-string])
           ([n (in-chunked-bytes x)])
           (chunked-string-append acc (string->chunked-string (number->string n 16))))))]
      [else (format "~a" x)]))

  (define (decode-value x) '())

  (define (universal-compare l r)
    (cond
      [(equal? l r) '=]
      [(and (number? l) (number? r)) (if (< l r) '< '>)]
      [(and (chunked-list? l) (chunked-list? r)) (chunked-list-compare/recur l r universal-compare)]
      [(and (chunked-string? l) (chunked-string? r))
       (chunked-string-compare/recur l r (lambda (a b) (if (char<? a b) '< '>)))]
      [(and (chunked-bytes? l) (chunked-bytes? r))
       (chunked-bytes-compare/recur l r (lambda (a b) (if (< a b) '< '>)))]
      [else (raise "universal-compare: unimplemented")]))

  (define (chunked-string<? l r) (chunked-string=?/recur l r char<?))

  (define (universal=? l r)
    (define (pointwise ll lr)
      (let ([nl (null? ll)] [nr (null? lr)])
        (cond
          [(and nl nr) #t]
          [(or nl nr) #f]
          [else
            (and (universal=? (car ll) (car lr))
                 (pointwise (cdr ll) (cdr lr)))])))
    (cond
      [(equal? l r) #t]
      [(and (chunked-list? l) (chunked-list? r))
       (chunked-list=?/recur l r universal=?)]
      [(and (data? l) (data? r))
       (and
         (eqv? (data-tag l) (data-tag r))
         (pointwise (data-fields l) (data-fields r)))]
      [else #f]))

  (define (exception->string e) (string->chunked-string (exn->string e)))

  (define (syntax->list stx)
    (syntax-case stx ()
      [() '()]
      [(x . xs) (cons #'x (syntax->list #'xs))]))

  (define (call-with-marks rs v f)
    (cond
      [(null? rs) (f)]
      [else
        (with-continuation-mark (car rs) v
          (call-with-marks (cdr rs) v f))]))

  (define-syntax let-marks
    (syntax-rules ()
      [(let-marks ks bn e ...)
       (call-with-marks ks bn (lambda () e ...))]))

  (define (ref-mark k) (continuation-mark-set-first #f k))

  (define (chunked-string-foldMap-chunks s m f)
    (for/fold
        ([acc empty-chunked-string])
        ([c (in-chunked-string-chunks s)])
      (f acc (string->chunked-string (m c)))))

  (define freeze-string! unsafe-string->immutable-string!)
  (define freeze-bytevector! unsafe-bytes->immutable-bytes!)

  (define freeze-vector! unsafe-vector*->immutable-vector!)

  ; racket string-copy! has the opposite argument order convention
  ; from chez.
  (define (string-copy! src soff dst doff len)
    (racket-string-copy! dst doff src soff len)))
