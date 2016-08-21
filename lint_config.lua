return {
  whitelist_globals = {
    ['.'] = {
      'instance', 'accessors', 'properties', 'include', 'parent', 'static', 'meta', 'missing_property', 'super'
    },
    ["spec"] = {
      'it', 'describe', 'before_each', 'before', 'after', 'after_each',
      'raise', 'spy', 'context', 'setup', 'teardown', 'moon', 'tr'
    }
  }
}
