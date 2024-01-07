# Start one or more units
export extern "systemctl start" [

	...args
]

# Stop one or more units
export extern "systemctl stop" [

	...args
]

# Restart one or more units
export extern "systemctl restart" [

	...args
]

# Runtime status about one or more units
export extern "systemctl status" [

	...args
]

# Enable one or more units
export extern "systemctl enable" [

	...args
]

# Disable one or more units
export extern "systemctl disable" [

	...args
]

# Start a unit and dependencies and disable all others
export extern "systemctl isolate" [

	...args
]

# Set the default target to boot into
export extern "systemctl set-default" [

	...args
]

# Sets one or more properties of a unit
export extern "systemctl set-property" [

	...args
]

# List of unit types
export extern "systemctl" [

	...args
]