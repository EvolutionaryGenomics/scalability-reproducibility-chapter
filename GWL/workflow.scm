(define-module (workflow)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix build-system trivial)
  #:use-module (guix download)
  #:use-module (guix build utils)
  #:use-module (guix utils)
  #:use-module (guix packages)
  #:use-module (guix processes)
  #:use-module (guix workflows)
  #:use-module (guix gexp)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages bioinformatics)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26)
  #:use-module (ice-9 format)
  #:use-module (ice-9 ftw))

(define %data-dir (string-append (getcwd) "/../data"))
(define %ctl-file (string-append %data-dir "/paml0-3.ctl"))
(define %clusters (scandir %data-dir (cut string-prefix? "cluster" <>)))

;; ----------------------------------------------------------------------------
;; PACKAGE DEFINITIONS
;; ----------------------------------------------------------------------------

;; So, with Guix, deployment is included, rather than forgotten.  That means
;; we have to package the things that aren't in Guix yet.  In this case,
;; that's the pal2nal script.
(define-public pal2nal
  (let ((commit "6340b36c85ed069676f4a0ebaf54286c4daca259"))
    (package
     (name "pal2nal")
     (version (string-append "14.1-" (string-take commit 7)))
     (source (origin
              (method url-fetch)
              (uri (string-append
                    "https://raw.githubusercontent.com/evolutionarygenomics/scalability-"
                    "reproducibility-chapter/" commit "/Docker/pal2nal.pl"))
              (file-name (string-append name "-" version))
              (sha256
               (base32 "0fqxccvdlc8fnc7xvxp6ljhcq3kqq6r67c46xag2cmsxdm3ma03i"))))
     (build-system trivial-build-system)
     (arguments
      `(#:modules ((guix build utils))
        #:builder
        (begin
          (use-modules (guix build utils))
          (let* ((bindir (string-append %output "/bin"))
                 (script (string-append bindir "/pal2nal.pl")))
            (mkdir-p bindir)
            (copy-file (assoc-ref %build-inputs "source") script)
            (substitute* script
              (("/usr/bin/perl")
               (string-append (assoc-ref %build-inputs "perl") "/bin/perl")))
            (chmod script #o555)))))
     (native-inputs `(("source" ,source)))
     (inputs `(("perl" ,perl)))
     (home-page "https://github.com/evolutionarygenomics/scalability-reproducibility-chapter/")
     (synopsis "...")
     (description "...")
     (license license:gpl2))))

;; ----------------------------------------------------------------------------
;; PROCESS DEFINITIONS
;; ----------------------------------------------------------------------------

(define (run-clustal cluster)
  (process
   (name (string-append "clustal-" cluster))
   (package-inputs (list clustal-omega))
   (procedure
    #~(system (string-append
               "clustalo -i " #$%data-dir "/" #$cluster "/aa.fa"
               " --guidetree-out=" #$%data-dir "/" #$cluster "/aa.ph"
               " > " #$%data-dir "/" #$cluster "/aa.aln")))))

(define (run-pal2nal cluster)
  (process
   (name (string-append "pal2nal-" cluster))
   (package-inputs (list pal2nal))
   (procedure
    #~(system (string-append
               "pal2nal.pl -output paml " #$%data-dir "/" #$cluster "/aa.aln "
               #$%data-dir "/" #$cluster "/nt.fa > "
               #$%data-dir "/" #$cluster "/alignment.phy")))))

(define (run-codeml cluster)
  (process
   (name (string-append "codeml-" cluster))
   (package-inputs (list paml))
   (procedure
    #~(begin
        (chdir (string-append #$%data-dir "/" #$cluster))
        (system (string-append "echo | codeml " #$%ctl-file))))))

;; ----------------------------------------------------------------------------
;; PROCESSES EXAMPLE
;; ----------------------------------------------------------------------------

;; Example to create separate processes for the 72 clusters.  This allows us
;; to run a single process using: $ guix process -r <name-of-the-process>
(for-each (lambda (cluster)
            (for-each (lambda (proc)
                        (define-dynamically
                          (string->symbol (process-full-name proc))
                          proc))
                      (list (run-clustal cluster)
                            (run-pal2nal cluster)
                            (run-codeml cluster))))
          %clusters)

;; ----------------------------------------------------------------------------
;; WORKFLOW EXAMPLE
;; ----------------------------------------------------------------------------

;; Example to combine all in a workflow.  This allows us to run all processes
;; using: $ guix workflow -r example-workflow
(define-public example-workflow
  (let* ((clustal-procs (map run-clustal %clusters))
         (pal2nal-procs (map run-pal2nal %clusters))
         (codeml-procs  (map run-codeml  %clusters)))
    (workflow
     (name "example-workflow")
     (processes (append clustal-procs pal2nal-procs codeml-procs))
     (restrictions
      (append (zip pal2nal-procs clustal-procs)
              (zip codeml-procs pal2nal-procs))))))
