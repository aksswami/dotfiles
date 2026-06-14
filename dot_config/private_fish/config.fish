if not set -q SSH_AUTH_SOCK
    eval (ssh-agent -c) > /dev/null
end

if status is-interactive
# Commands to run in interactive sessions can go here
end

if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv fish | source
end

if not set -q NODE_EXTRA_CA_CERTS
    set -gx NODE_EXTRA_CA_CERTS "$HOME/zscaler.pem"
end