define oradb_fs::sig_file_loop(
 String         $home             = '', 
 String         $product          = '',
 String         $sig_version      = '1.0',
 String         $type             = '',
 String         $sig_desc         = '',
 Array[String]  $global_name      = '',
 String         $scanid           = '',
 String         $nodeid           = '',
 String         $oracle_home      = '',
 String         $sig_file_name    = undef,
 String         $home_path        = undef,
)
{

 $short_home_path = split($home_path,'/')[-1]

 $global_name.each | String $sid | {
  $holding = $sid.split(':')
  oradb_fs::sig_file { "Patch sig file for ${sig_desc} : ${home} : ${sid}" : 
   product          => $product,
   sig_version      => $sig_version,
   type             => $type,
   sig_desc         => $sig_desc,
   global_name      => $holding[0],
   scanid           => $scanid,
   nodeid           => $node_id,
   oracle_home      => $oracle_home,
   sig_file_name    => "${sig_file_name}_${sid}_${short_home_path}",
  } 
 }
}
