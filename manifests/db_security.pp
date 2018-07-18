define oradb_fs::db_security (
 String    $db_name              = undef,
 String    $working_dir          = undef,
 String    $home                 = undef,
 String    $home_path            = undef,
 String    $db_security_options  = undef,
)
{
 $holding = split($db_security_options,'~')
 file { "${working_dir}/fs_db_admin_boostrap_${db_name}.sql":
  ensure  => 'file',
  owner   => 'oracle',
  group   => 'oinstall',
  mode    => '0644',
  source  => 'puppet:///modules/oradb_fs/security_compromise/fs_db_admin_boostrap.sql'
 }
 file { "${working_dir}/fs_exists_functions_${db_name}.sql":
  ensure  => 'file',  
  owner   => 'oracle',
  group   => 'oinstall',
  mode    => '0644',
  source  => 'puppet:///modules/oradb_fs/security_compromise/fs_exists_functions.sql'
 }
 file { "${working_dir}/fs_puppet_format_output_${db_name}.sql":
  ensure  => 'file',
  owner   => 'oracle',
  group   => 'oinstall',
  mode    => '0644',
  source  => 'puppet:///modules/oradb_fs/security_compromise/fs_puppet_format_output.sql'
 }
 file { "${working_dir}/fs_puppet_structures_${db_name}.sql":
  ensure  => 'file',
  owner   => 'oracle',
  group   => 'oinstall',
  mode    => '0644',
  source  => 'puppet:///modules/oradb_fs/security_compromise/fs_puppet_structures.sql'
 }
 file { "${working_dir}/fs_security_pkg_${db_name}.sql":
  ensure  => 'file',
  owner   => 'oracle',
  group   => 'oinstall',
  mode    => '0644',
  source  => 'puppet:///modules/oradb_fs/security_compromise/fs_security_pkg.sql'
 }
 file { "${working_dir}/fs_password_verify_${db_name}.sql":
  ensure  => 'file',
  owner   => 'oracle',
  group   => 'oinstall',
  mode    => '0644',
  source  => 'puppet:///modules/oradb_fs/security_compromise/fs_password_verify.sql'
 }
 file { "${working_dir}/revoke_public_grants_${db_name}.sql":
  ensure  => 'file',
  owner   => 'oracle',
  group   => 'oinstall',
  mode    => '0644',
  source  => 'puppet:///modules/oradb_fs/security_compromise/revoke_public_grants.sql'
 }

 file { "${working_dir}/security_compromise_${db_name}.sql":
  ensure   => 'file',
  content  => epp("oradb_fs/security_compromise.sql.epp",
                 { 'roles'           => $holding[0],
                   'profiles'        => $holding[1],
                   'public_grants'   => $holding[2],
                   'users'           => $holding[3],
                   'basic_security'  => $holding[4],
                   'legacy_objects'  => $holding[5],
                   'gis_roles'       => $holding[6] }),
  owner    => 'oracle',
  group    => 'oinstall',
  mode     => '0644',
 }
 exec {"Create FS_DB_ADMIN if needed : ${home} : ${db_name}":
  command      => "sqlplus /nolog @${working_dir}/fs_db_admin_boostrap_${db_name}.sql",
  user         => 'oracle',
  path         => "${home_path}/bin",
  environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
  require      => File["${working_dir}/fs_db_admin_boostrap_${db_name}.sql"],
  before       => [ Exec["Build fs_puppet_format_output inside DB : ${home} : ${db_name}"], Exec["Build fs_exists_functions inside DB : ${home} : ${db_name}"] ]
 }
 exec {"Build fs_password_verify inside DB : ${home} : ${db_name}":
  command      => "sqlplus /nolog @${working_dir}/fs_password_verify_${db_name}.sql",
  user         => 'oracle',
  path         => "${home_path}/bin",
  environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
  require      => File["${working_dir}/fs_password_verify_${db_name}.sql"],
 }
 exec {"Build fs_exists_functions inside DB : ${home} : ${db_name}":
  command      => "sqlplus /nolog @${working_dir}/fs_exists_functions_${db_name}.sql",
  user         => 'oracle',
  path         => "${home_path}/bin",
  environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
  require      => File["${working_dir}/fs_exists_functions_${db_name}.sql"],
  before       => [ Exec["Build fs_puppet_structures inside DB : ${home} : ${db_name}"] , Exec["Build fs_security_pkg inside DB : ${home} : ${db_name}"] ]
 }
 exec {"Build fs_puppet_format_output inside DB : ${home} : ${db_name}":
  command      => "sqlplus /nolog @${working_dir}/fs_puppet_format_output_${db_name}.sql",
  user         => 'oracle',
  path         => "${home_path}/bin",
  environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
  require      => File["${working_dir}/fs_puppet_format_output_${db_name}.sql"],
  before       => [ Exec["Build fs_puppet_structures inside DB : ${home} : ${db_name}"] , Exec["Build fs_security_pkg inside DB : ${home} : ${db_name}"] ]
 }
 exec {"Build fs_puppet_structures inside DB : ${home} : ${db_name}":
  command    => "sqlplus /nolog @${working_dir}/fs_puppet_structures_${db_name}.sql",
  user         => 'oracle',
  path         => "${home_path}/bin",
  environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
  require      => File["${working_dir}/fs_puppet_structures_${db_name}.sql"]
 }
 exec {"Build fs_security_pkg inside DB : ${home} : ${db_name}":
  command      => "sqlplus /nolog @${working_dir}/fs_security_pkg_${db_name}.sql",
  user         => 'oracle',
  path         => "${home_path}/bin",
  environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
  require      => File["${working_dir}/fs_security_pkg_${db_name}.sql"]
 }
 exec {"Build revoke_public_grants inside DB : ${home} : ${db_name}":
  command      => "sqlplus /nolog @${working_dir}/revoke_public_grants_${db_name}.sql",
  user         => 'oracle',
  path         => "${home_path}/bin",
  environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
  require      => File["${working_dir}/revoke_public_grants_${db_name}.sql"]
 }

 if $holding[0] in [ 'c', 'b', 's', 'h' ] {
  if $holding[1] in [ 'c', 's' ] {
   if $holding[2] in [ 'c', 's' ] {
    if $holding[3] in [ 'c', 'b', 'h', 's' ] {
     if $holding[4] in [ 'c', 's' ] {
      if $holding[5] in [ 'c', 's' ] {
       if $holding[6] in [ 't', 'f' ] {
        if $holding[3] == 's' {
         file { "${working_dir}/fs_public_grants_update_${db_name}.sql":
          ensure  => 'file',
          owner   => 'oracle',
          group   => 'oinstall',
          mode    => '0644',
          source  => 'puppet:///modules/oradb_fs/security_compromise/fs_public_grants_update.sql'
         }
         exec {"Update public grants before security change for DB : ${home} : ${db_name}":
          command      => "sqlplus /nolog @${working_dir}/fs_public_grants_update_${db_name}.sql",
          user         => 'oracle',
          path         => "${home_path}/bin",
          environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
          require      => File["${working_dir}/fs_public_grants_update_${db_name}.sql"],
          before       => Exec["Run security_compromise against DB : ${home} : ${db_name}"]
         }
        }   
        exec {"Run security_compromise against DB : ${home} : ${db_name}":
         command      => "sqlplus /nolog @${working_dir}/security_compromise_${db_name}.sql",
         user         => 'oracle',
         path         => "${home_path}/bin",
         environment  => [ "ORACLE_BASE=/opt/oracle", "ORACLE_HOME=${home_path}", "ORACLE_SID=${db_name}", "LD_LIBRARY_PATH=${home_path}/lib"],
         require      => [ File["${working_dir}/security_compromise_${db_name}.sql"], Exec["Build fs_exists_functions inside DB : ${home} : ${db_name}"], Exec["Build fs_puppet_format_output inside DB : ${home} : ${db_name}"], Exec["Build fs_puppet_structures inside DB : ${home} : ${db_name}"], Exec["Build fs_security_pkg inside DB : ${home} : ${db_name}"], Exec["Build fs_password_verify inside DB : ${home} : ${db_name}"] ]
        }
       }
       else {
        notify { "Security options for SID not recognized. Update FQDN.yaml file and run remediation for SID : ${home} : ${db_name} : position 7 - ${holding[6]}" :
         loglevel => 'err'
        }
       }
      }
      else {
       notify { "Security options for SID not recognized. Update FQDN.yaml file and run remediation for SID : ${home} : ${db_name} : position 6 - ${holding[5]}" :
        loglevel => 'err'
       }
      }
     }
     else {
      notify { "Security options for SID not recognized. Update FQDN.yaml file and run remediation for SID : ${home} : ${db_name} : position 5 - ${holding[4]}" :
       loglevel => 'err'
      }
     }
    }
    else {
     notify { "Security options for SID not recognized. Update FQDN.yaml file and run remediation for SID : ${home} : ${db_name} : position 4 - ${holding[3]}" :
      loglevel => 'err'
     }
    }
   }
   else {
    notify { "Security options for SID not recognized. Update FQDN.yaml file and run remediation for SID : ${home} : ${db_name} : position 3 - ${holding[2]}" :
     loglevel => 'err'
    }
   }
  }
  else {
   notify { "Security options for SID not recognized. Update FQDN.yaml file and run remediation for SID : ${home} : ${db_name} : position 2 - ${holding[1]}" :
    loglevel => 'err'
   }
  }
 }
 else {
  notify { "Security options for SID not recognized. Update FQDN.yaml file and run remediation for SID : ${home} : ${db_name} : position 1 - ${holding[0]}" :
   loglevel => 'err'
  }
 }
}


