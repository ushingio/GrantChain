;; GrantChain: Research Grant Application and Funding Management System
;; Version: 1.0.0

(define-constant ERR-NOT-AUTHORIZED (err u1))
(define-constant ERR-GRANT-NOT-FOUND (err u2))
(define-constant ERR-ALREADY-SUBMITTED (err u3))
(define-constant ERR-INVALID-STATUS (err u4))
(define-constant ERR-INVALID-FUNDING-AMOUNT (err u5))
(define-constant ERR-INVALID-FUNDING-AGENCY (err u6))
(define-constant ERR-INVALID-GRANT-TYPE (err u7))
(define-constant ERR-INVALID-GRANT-TITLE (err u8))
(define-constant ERR-INVALID-PROPOSAL (err u9))

(define-constant MIN-FUNDING-AMOUNT u1000)

(define-data-var next-grant-id uint u1)

(define-map grant-registry
    uint
    {
        applicant: principal,
        grant-title: (string-utf8 50),
        proposal: (string-utf8 200),
        funding-agency: (string-utf8 15),
        grant-type: (string-utf8 10),
        application-status: (string-utf8 15),
        funding-amount: uint
    })

(define-private (validate-funding-agency (funding-agency (string-utf8 15)))
    (or 
        (is-eq funding-agency u"NSF")
        (is-eq funding-agency u"NIH")
        (is-eq funding-agency u"DOE")
        (is-eq funding-agency u"NASA")
        (is-eq funding-agency u"DARPA")
        (is-eq funding-agency u"Private")
    ))

(define-private (validate-grant-type (grant-type (string-utf8 10)))
    (or 
        (is-eq grant-type u"Basic")
        (is-eq grant-type u"Applied")
        (is-eq grant-type u"SBIR")
        (is-eq grant-type u"Fellowship")
        (is-eq grant-type u"Equipment")
    ))

(define-private (validate-text-input (text (string-utf8 200)) (min-length uint) (max-length uint))
    (let 
        (
            (text-length (len text))
        )
        (and 
            (>= text-length min-length)
            (<= text-length max-length)
        )
    ))

(define-public (apply-for-grant 
    (grant-title (string-utf8 50))
    (proposal (string-utf8 200))
    (funding-agency (string-utf8 15))
    (grant-type (string-utf8 10))
    (funding-amount uint))
    (let
        (
            (grant-id (var-get next-grant-id))
        )
        (asserts! (validate-text-input grant-title u3 u50) ERR-INVALID-GRANT-TITLE)
        (asserts! (validate-text-input proposal u10 u200) ERR-INVALID-PROPOSAL)
        (asserts! (>= funding-amount MIN-FUNDING-AMOUNT) ERR-INVALID-FUNDING-AMOUNT)
        (asserts! (validate-funding-agency funding-agency) ERR-INVALID-FUNDING-AGENCY)
        (asserts! (validate-grant-type grant-type) ERR-INVALID-GRANT-TYPE)
        
        (map-set grant-registry grant-id {
            applicant: tx-sender,
            grant-title: grant-title,
            proposal: proposal,
            funding-agency: funding-agency,
            grant-type: grant-type,
            application-status: u"pending",
            funding-amount: funding-amount
        })
        (var-set next-grant-id (+ grant-id u1))
        (ok grant-id)
    ))

(define-public (award-grant (grant-id uint))
    (let
        (
            (grant (unwrap! (map-get? grant-registry grant-id) ERR-GRANT-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get applicant grant)) ERR-NOT-AUTHORIZED)
        (asserts! (is-eq (get application-status grant) u"pending") ERR-INVALID-STATUS)
        (ok (map-set grant-registry grant-id (merge grant { application-status: u"awarded" })))
    ))

(define-read-only (get-grant (grant-id uint))
    (ok (map-get? grant-registry grant-id)))

(define-read-only (get-applicant (grant-id uint))
    (ok (get applicant (unwrap! (map-get? grant-registry grant-id) ERR-GRANT-NOT-FOUND))))

(define-read-only (get-total-grants)
    (ok (- (var-get next-grant-id) u1)))

(define-read-only (get-application-status (grant-id uint))
    (ok (get application-status (unwrap! (map-get? grant-registry grant-id) ERR-GRANT-NOT-FOUND))))