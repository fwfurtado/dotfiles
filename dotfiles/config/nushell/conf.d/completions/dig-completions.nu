# Use IPv4 query transport only
export extern "dig" [

	...args
]

# TCP mode
export extern "dig +vc +novc" [

	...args
]

# TCP mode, alternate syntax
export extern "dig +tcp +notcp" [

	...args
]

# Set whether to use searchlist
export extern "dig +search +nosearch" [

	...args
]

# Search with intermediate results
export extern "dig +showsearch +noshowsearch" [

	...args
]

# Deprecated, treated as a synonym for +[no]search
export extern "dig +defname +nodefname" [

	...args
]

# Recursive mode
export extern "dig +recurse +norecurse" [

	...args
]

# Dont revert to TCP for TC responses.
export extern "dig +ignore +noignore" [

	...args
]

# Dont try next server on SERVFAIL
export extern "dig +fail +nofail" [

	...args
]

# Try to parse even illegal messages
export extern "dig +besteffort +nobesteffort" [

	...args
]

# Set AA flag in query (+[no]aaflag)
export extern "dig +aaonly +noaaonly" [

	...args
]

# Set AD flag in query
export extern "dig +adflag +noadflag" [

	...args
]

# Set CD flag in query
export extern "dig +cdflag +nocdflag" [

	...args
]

# Control display of class in records
export extern "dig +cl +nocl" [

	...args
]

# Control display of command line
export extern "dig +cmd +nocmd" [

	...args
]

# Control display of comment lines
export extern "dig +comments +nocomments" [

	...args
]

# Control display of question
export extern "dig +question +noquestion" [

	...args
]

# Control display of answer
export extern "dig +answer +noanswer" [

	...args
]

# Control display of authority
export extern "dig +authority +noauthority" [

	...args
]

# Control display of additional
export extern "dig +additional +noadditional" [

	...args
]

# Control display of statistics
export extern "dig +stats +nostats" [

	...args
]

# Disable everything except short form of answer
export extern "dig +short +noshort" [

	...args
]

# Control display of ttls in records
export extern "dig +ttlid +nottlid" [

	...args
]

# Set or clear all display flags
export extern "dig +all +noall" [

	...args
]

# Print question before sending
export extern "dig +qr +noqr" [

	...args
]

# Search all authoritative nameservers
export extern "dig +nssearch +nonssearch" [

	...args
]

# ID responders in short answers
export extern "dig +identify +noidentify" [

	...args
]

# Trace delegation down from root
export extern "dig +trace +notrace" [

	...args
]

# Request DNSSEC records
export extern "dig +dnssec +nodnssec" [

	...args
]

# Request Name Server ID
export extern "dig +nsid +nonsid" [

	...args
]

# Print records in an expanded format
export extern "dig +multiline +nomultiline" [

	...args
]

# AXFR prints only one soa record
export extern "dig +onesoa +noonesoa" [

	...args
]

# Set number of UDP attempts
export extern "dig +tries=" [

	...args
]

# Set number of UDP retries
export extern "dig +retry=" [

	...args
]

# Set query timeout
export extern "dig +time=" [

	...args
]

# Set EDNS0 Max UDP packet size
export extern "dig +bufsize=" [

	...args
]

# Set NDOTS value
export extern "dig +ndots=" [

	...args
]

# Set EDNS version
export extern "dig +edns=" [

	...args
]