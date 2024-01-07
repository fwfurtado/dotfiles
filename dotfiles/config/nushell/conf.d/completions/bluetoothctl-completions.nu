# List available controllers
export extern "bluetoothctl list" [

	...args
]

# Controller information
export extern "bluetoothctl show" [

	...args
]

# Select default controller
export extern "bluetoothctl select" [

	...args
]

# List available devices
export extern "bluetoothctl devices" [

	...args
]

# List paired devices
export extern "bluetoothctl paired-devices" [

	...args
]

# Set controller alias
export extern "bluetoothctl system-alias" [

	...args
]

# Reset controller alias
export extern "bluetoothctl reset-alias" [

	...args
]

# Set controller power
export extern "bluetoothctl power" [

	...args
]

# Set controller pairable mode
export extern "bluetoothctl pairable" [

	...args
]

# Set controller discoverable mode
export extern "bluetoothctl discoverable" [

	...args
]

# Set discoverable timeout
export extern "bluetoothctl discoverable-timeout" [

	...args
]

# Enable/disable agent with given capability
export extern "bluetoothctl agent" [

	...args
]

# Set agent as the default one
export extern "bluetoothctl default-agent" [

	...args
]

# Enable/disable advertising with given type
export extern "bluetoothctl advertise" [

	...args
]

# Set device alias
export extern "bluetoothctl set-alias" [

	...args
]

# Scan for devices
export extern "bluetoothctl scan" [

	...args
]

# Device information
export extern "bluetoothctl info" [

	...args
]

# Pair with device
export extern "bluetoothctl pair" [

	...args
]

# Cancel pairing with device
export extern "bluetoothctl cancel-pairing" [

	...args
]

# Trust device
export extern "bluetoothctl trust" [

	...args
]

# Untrust device
export extern "bluetoothctl untrust" [

	...args
]

# Block device
export extern "bluetoothctl block" [

	...args
]

# Unblock device
export extern "bluetoothctl unblock" [

	...args
]

# Remove device
export extern "bluetoothctl remove" [

	...args
]

# Connect device
export extern "bluetoothctl connect" [

	...args
]

# Disconnect device
export extern "bluetoothctl disconnect" [

	...args
]

# Set/Get advertise uuids
export extern "bluetoothctl scan.uuids" [

	...args
]

# Set/Get advertise service data
export extern "bluetoothctl scan.service" [

	...args
]

# Set/Get advertise manufacturer data
export extern "bluetoothctl scan.manufacturer" [

	...args
]

# Set/Get advertise data
export extern "bluetoothctl scan.data" [

	...args
]

# Set/Get advertise discoverable
export extern "bluetoothctl scan.discoverable" [

	...args
]

# Set/Get advertise discoverable timeout
export extern "bluetoothctl scan.discoverable-timeout" [

	...args
]

# Show/Enable/Disable TX power to be advertised
export extern "bluetoothctl scan.tx-power" [

	...args
]

# Configure local name to be advertised
export extern "bluetoothctl scan.name" [

	...args
]

# Configure custom appearance to be advertised
export extern "bluetoothctl scan.appearance" [

	...args
]

# Set/Get advertise duration
export extern "bluetoothctl scan.duration" [

	...args
]

# Set/Get advertise timeout
export extern "bluetoothctl scan.timeout" [

	...args
]

# Set/Get advertise secondary channel
export extern "bluetoothctl scan.secondary" [

	...args
]

# Clear advertise config
export extern "bluetoothctl scan.clear" [

	...args
]

# List attributes
export extern "bluetoothctl gatt.list-attributes" [

	...args
]

# Select attribute
export extern "bluetoothctl gatt.select-attribute" [

	...args
]

# Select attribute
export extern "bluetoothctl gatt.attribute-info" [

	...args
]

# Read attribute value
export extern "bluetoothctl gatt.read" [

	...args
]

# Write attribute value
export extern "bluetoothctl gatt.write" [

	...args
]

# Acquire Write file descriptor
export extern "bluetoothctl gatt.acquire-write" [

	...args
]

# Release Write file descriptor
export extern "bluetoothctl gatt.release-write" [

	...args
]

# Acquire Notify file descriptor
export extern "bluetoothctl gatt.acquire-notify" [

	...args
]

# Release Notify file descriptor
export extern "bluetoothctl gatt.release-notify" [

	...args
]

# Notify attribute value
export extern "bluetoothctl gatt.notify" [

	...args
]

# Clone a device or attribute
export extern "bluetoothctl gatt.clone" [

	...args
]

# Register profile to connect
export extern "bluetoothctl gatt.register-application" [

	...args
]

# Unregister profile
export extern "bluetoothctl gatt.unregister-application" [

	...args
]

# Register application service
export extern "bluetoothctl gatt.register-service" [

	...args
]

# Unregister application service
export extern "bluetoothctl gatt.unregister-service" [

	...args
]

# Register as Included service in
export extern "bluetoothctl gatt.register-includes" [

	...args
]

# Unregister Included service
export extern "bluetoothctl gatt.unregister-includes" [

	...args
]

# Register application characteristic
export extern "bluetoothctl gatt.register-characteristic" [

	...args
]

# Unregister application characteristic
export extern "bluetoothctl gatt.unregister-characteristic" [

	...args
]

# Register application descriptor
export extern "bluetoothctl gatt.register-descriptor" [

	...args
]

# Unregister application descriptor
export extern "bluetoothctl gatt.unregister-descriptor" [

	...args
]

# Set/Get advertise uuids
export extern "bluetoothctl advertise.uuids" [

	...args
]

# Set/Get advertise service data
export extern "bluetoothctl advertise.service" [

	...args
]

# Set/Get advertise manufacturer data
export extern "bluetoothctl advertise.manufacturer" [

	...args
]

# Set/Get advertise data
export extern "bluetoothctl advertise.data" [

	...args
]

# Set/Get advertise discoverable
export extern "bluetoothctl advertise.discoverable" [

	...args
]

# Set/Get advertise discoverable timeout
export extern "bluetoothctl advertise.discoverable-timeout" [

	...args
]

# Show/Enable/Disable TX power to be advertised
export extern "bluetoothctl advertise.tx-power" [

	...args
]

# Configure local name to be advertised
export extern "bluetoothctl advertise.name" [

	...args
]

# Configure custom appearance to be advertised
export extern "bluetoothctl advertise.appearance" [

	...args
]

# Set/Get advertise duration
export extern "bluetoothctl advertise.duration" [

	...args
]

# Set/Get advertise timeout
export extern "bluetoothctl advertise.timeout" [

	...args
]

# Set/Get advertise secondary channel
export extern "bluetoothctl advertise.secondary" [

	...args
]

# Clear advertise config
export extern "bluetoothctl advertise.clear" [

	...args
]

# 
export extern "bluetoothctl on off" [

	...args
]