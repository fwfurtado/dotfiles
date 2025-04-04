function _bastion-ip
	if test "$argv[1]" = "prod"
		echo "18.188.136.81"
		return
	end

	echo "3.142.52.149"
end

function _bastion-bind-help
	echo "help"
end

function bastion-bind
	argparse 'env=+!string match -rq "\bdev\b|\bprod\b" "$_flag_value"' 'host=+' 'remote-port=!_validate_int --min 1 --max 65535' 'local-port=!_validate_int --min 1 --max 65535' 'h/help=?' -- $argv
	or else

	if set -ql _flag_h
		_bastion-bind-help
		return
	end

	set -l missing_arguments "env, host and remote port are required" 

	if not set -ql _flag_env
		echo $missing_arguments
		_bastion-bind-help
		return
	end

	if not set -ql _flag_host
		echo $missing_arguments
		_bastion-bind-help
		return
	end


	if not set -ql _flag_remote_port
		echo $missing_arguments
		_bastion-bind-help
		return
	end

	set -l env $_flag_env
	set -l host $_flag_host
	set -l remote_port $_flag_remote_port
	set -l local_port $_flag_remote_port


	if set -ql _flag_local_port
		set local_port $_flag_local_port
	end

	set -l bind_addr "$local_port:$host:$remote_port"
	set -l bastion_ip (_bastion-ip $env)

	ssh -i ~/bastion.pem -L $bind_addr ec2-user@$bastion_ip
end
