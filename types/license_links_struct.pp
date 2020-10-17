type Workstation::License_links_struct = Struct[
  {
    Optional[replicated] => Array[Workstation::Absolute_path],
    Optional[cd4pe]      => Array[Workstation::Absolute_path],
  }
]
