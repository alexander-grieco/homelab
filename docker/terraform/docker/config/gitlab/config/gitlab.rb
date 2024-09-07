
gitlab_rails['gitlab_shell_ssh_port'] = 2424

external_url 'https://gitlab.local.alexgrieco.io'

letsencrypt['enable'] = false

nginx['listen_port'] = 80
nginx['listen_https'] = false

