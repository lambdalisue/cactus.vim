let s:ESCAPE_PATTERN = '^$~.*[]\'

function! cactus#internal#query#parse(input) abort
  if empty(a:input)
    return []
  endif
  let q = substitute(a:input, '^\s\+\|\s\+$', '', 'g')
  let q = split(q, '\s*\%(\\\)\@<!|\s*')
  call map(q, { -> substitute(v:val, '\\|', '|', 'g') })
  call map(q, { -> split(v:val, '\s*\%(\\\)\@<!\s\s*') })
  call map(q, { -> map(v:val, { -> substitute(v:val, '\\ ', ' ', 'g') }) })
  return q
endfunction

function! cactus#internal#query#filter(query, candidates, threshold) abort
  let pattern = s:build_pattern(a:query)
  let indices = []
  let counter = 0
  let index = -1
  while counter < a:threshold
    let index = match(a:candidates, pattern, index + 1)
    if index is# -1
      break
    endif
    call add(indices, index)
    let counter += 1
  endwhile
  return indices
endfunction

function! s:build_pattern(query) abort
  let q = copy(a:query)
  call map(q, { -> map(v:val, { -> escape(v:val, s:ESCAPE_PATTERN) }) })
  call map(q, { -> map(v:val, { -> printf('\%%(.*%s\)\@=', v:val) }) })
  call map(q, { -> printf('%s.*', join(v:val, '')) })
  return printf('\c^%s$', join(q, '\|'))
endfunction
