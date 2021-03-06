def f(opts):
  opts.extra_hc_opts = '-XTemplateHaskell -package template-haskell'
  if (ghc_with_interpreter == 0):
	opts.skip = 1

setTestOpts(f)
setTestOpts(only_compiler_types(['ghc']))
setTestOpts(only_ways(['normal','ghci']))
setTestOpts(if_compiler_profiled(skip))

test('TH_spliceViewPat', normal, multimod_compile_and_run, [ 'Main', '' ])
