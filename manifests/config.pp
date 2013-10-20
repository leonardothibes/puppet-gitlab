#init -> packages -> user -> setup -> install -> config -> service
class gitlab::config inherits gitlab {

  #All file resource declarations should be executed as git:git
  File {
    owner   => "${gitlab::git_user}",
    group   => 'git',
  }


  #Create log directory
  file { "${gitlab::git_home}/gitlab/log":
    ensure  => directory,
    mode    => '0755',
  }

  #Create tmp directory
  file { "${gitlab::git_home}/gitlab/tmp":
    ensure  =>  directory,
    mode    =>  '0755',
  }

  #Create pids directory
  file { "${gitlab::git_home}/gitlab/tmp/pids" :
    ensure  =>  directory,
    mode    =>  '0755',
  }

  #Create socket directory
  file { "${gitlab::git_home}/gitlab/tmp/sockets" :
    ensure  =>  directory,
    mode    =>  '0755',
  }

  #Create satellites directory
  file { "${gitlab::git_home}/gitlab-satellites":
    ensure    =>  directory,
    mode      =>  '0755',
  }

  #Create public/uploads directory otherwise backups will fail
  file { "${gitlab::git_home}/gitlab/public/uploads":
    ensure    =>  directory,
    mode      =>  '0755',
  }

  #Create nginx sites-available directory
  file { '/etc/nginx/sites-available':
    ensure    =>  directory,
    owner     =>  'root',
    group     =>  'root',
  }

  #Create nginx sites-enabled directory
  file { '/etc/nginx/sites-enabled':
    ensure    =>  directory,
    owner     =>  'root',
    group     =>  'root',
  }

  #Copy nginx config to sites-available
  file { '/etc/nginx/sites-available/gitlab':
    ensure    =>  file,
    content   =>  template('gitlab/nginx-gitlab.conf.erb'),
    mode      =>  '0644',
    owner     =>  'root',
    group     =>  'root',
  }

  #Create symbolic link
  file  { '/etc/nginx/sites-enabled/gitlab':
    ensure    =>  link,
    target    =>  '/etc/nginx/sites-available/gitlab',
    owner     =>  'root',
    group     =>  'root',
  }


#  file { "${gitlab::params::git_home}/.gitconfig":
#    ensure    => file,
#    content   => template('gitlab/gitconfig.erb'),
#    mode      => '0644',
#    owner     => "${gitlab::git_user}",
#  }

#  Setup global git user
  exec { 'git config --global user.name':
    path          =>  '/usr/bin:/usr/local/bin',
    environment   =>  'HOME=/home/git',   #http://projects.puppetlabs.com/issues/5224
    #environment  =>  '/root',
    #user         =>  "${gitlab::params::git_user}",
    command       =>  "git config --global user.name ${gitlab::git_comment}",
  }

  #Setup global git email
  exec { 'git config --global user.email':
    path          =>  '/usr/bin:/usr/local/bin',
    environment   =>  'HOME=/home/git',  #http://projects.puppetlabs.com/issues/5224
    #environment  =>  '/root',
    #user         =>  "${gitlab::git_user}",
    command       =>  "git config --global user.email ${gitlab::git_email}",
  }

  #Setup global core.autocrlf input
  exec { 'git config --global core.autocrlf input':
    path          =>  '/usr/bin:/usr/local/bin',
    environment   =>  'HOME=/home/git',  #http://projects.puppetlabs.com/issues/5224
    #environment  =>  '/root',
    #user         =>  "${gitlab::git_user}",
    command       =>  'git config --global core.autocrlf input',
    #TODO: Force this to not just run once
  }

  #Set owner and permissions of /home/git/.gitconfig
  file { "${gitlab::params::git_home}/.gitconfig":
    ensure  =>  file,
    owner   =>  "${gitlab::git_user}",
    group   =>  'git',
    mode    =>  '0644',
  }

  #Thumbnail logo white default
  file{"${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-white.png":
    source  =>  'puppet:///modules/gitlab/gitlab-logo-white.png.erb',
    owner   =>  "${gitlab::git_user}",
    group   =>  'git',
    mode    =>  '0644',
    backup  =>  false,
  }

  #Thumbnail logo black default
  file{"${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-black.png":
    source  =>  'puppet:///modules/gitlab/gitlab-logo-black.png.erb',
    owner   =>  "${gitlab::git_user}",
    group   =>  'git',
    mode    =>  '0644',
    backup  =>  false,
  }


  #Overwrite gitlab icons with custom icons
  #The origional icon is left intact and a symbolic link is used to point to logo-white.png
  case "${gitlab::use_custom_thumbnail}" {


      'true': {
        notify{'Setting thumbnail icon to custom icon':}

        #Set the thumbnails  to the custom icons in the gitlab/files directory
        file{ "${gitlab::git_home}/gitlab/app/assets/images/logo-white.png":
          ensure  =>  link,
          target  =>  "${gitlab::git_home}/company-logo-white.png",
          backup  =>  false,
          owner   =>  "${gitlab::git_user}",
          group   =>  'git',
          mode    =>  '0644',
          require =>  [
                  File["${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-white.png"],
                  File["${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-black.png"],
                  ],
        }
        file{ "${gitlab::git_home}/gitlab/app/assets/images/logo-black.png":
          ensure  =>  link,
          target  =>  "${gitlab::git_home}/company-logo-black.png",
          backup  =>  false,
          owner   =>  "${gitlab::git_user}",
          group   =>  'git',
          mode    =>  '0644',
          require =>  [
                  File["${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-white.png"],
                  File["${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-black.png"],
                  ],
        }

      }#end true

      'false':  {
        notify{'Setting thumbnail icon to default gitlab':}

        #Set the thumbnails to the default desert fox icon
        file{ "${gitlab::git_home}/gitlab/app/assets/images/logo-white.png":
          ensure  =>  link,
          target  =>  "${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-white.png",
          backup  =>  false,
          owner   =>  "${gitlab::git_user}",
          group   =>  'git',
          mode    =>  '0644',
          require =>  [
                  File["${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-white.png"],
                  File["${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-black.png"],
                  ],
        }
        file{ "${gitlab::git_home}/gitlab/app/assets/images/logo-black.png":
          ensure  =>  link,
          target  =>  "${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-black.png",
          backup  =>  false,
          owner   =>  "${gitlab::git_user}",
          group   =>  'git',
          mode    =>  '0644',
          require =>  [
                  File["${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-white.png"],
                  File["${gitlab::git_home}/gitlab/app/assets/images/gitlab-logo-black.png"],
                  ],
        }
      }#end false

      default:
      {
        fail("use_custom_thumbnail was set to ${gitlab::use_custom_thumbnail} which is neither false nor true")
      }

  }#end case


}#end config.pp
