class nginx::install {
    package { 'nginx':
        ensure => installed,
        require => Class['php']
    }

    exec { 'add-apt-repository ppa:nginx':
        command => '/usr/bin/add-apt-repository ppa:nginx/stable',
        require => Package["python-software-properties"],
    }

    exec { 'apt-get update for latest nginx':
        command => '/usr/bin/apt-get update',
        before => Package['nginx'],
        require => Exec['add-apt-repository ppa:nginx'],
    }
}

class nginx::configure {
}

class nginx::run {
    service { nginx:
        enable => true,
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        require => Class['nginx::install', 'nginx::configure'],
    }
}

define addServer( $site, $root ) {
    $sitesavailable = '/etc/nginx/sites-available'
    $sitesenabled = '/etc/nginx/sites-enabled'
    $template = 'nginx/nginx.erb'
    $server_name = "$site"
    file {"$sitesavailable/$site":
        content => template($template),
        owner   => 'root',
        group   => 'root',
        mode    => '755',
        require => Package['nginx'],
        notify  => Service['nginx']
    }
    file { "$sitesenabled/$site":
        ensure => 'link',
        target => "$sitesavailable/$site",
        require => Package['nginx'],
        notify  => Service['nginx']
    }
}

class nginx {
    include nginx::install
    include nginx::configure
    include nginx::run
}