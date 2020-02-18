let s:escape_pattern = '^$~.*[]\'

function! cactus#internal#filter#apply(pattern, candidates, threshold) abort
  if empty(a:pattern)
    return {
          \ 'content': reverse(a:candidates[: a:threshold - 1]),
          \ 'matches': [],
          \}
  endif
  let content = []
  let matches = []
  let counter = 0
  let index = 0
  let n = len(a:candidates)
  while counter < a:threshold && index < n
    let m = matchstrpos(a:candidates, a:pattern, index)
    if empty(m[0])
      break
    endif
    call add(content, a:candidates[m[1]])
    call add(matches, m[1:])
    let index = m[1] + 1
    let counter += 1
  endwhile
  return {
        \ 'content': reverse(content),
        \ 'matches': reverse(matches),
        \}
endfunction

function! cactus#internal#filter#exact(query) abort
  return empty(a:query) ? '' : printf('^%s$', escape(a:query, s:escape_pattern))
endfunction

function! cactus#internal#filter#fuzzy(query) abort
  if empty(a:query)
    return ''
  endif
  let chars = map(split(a:query, '\zs'), { _, v -> escape(v, s:escape_pattern) })
  let pattern = join(map(chars[:-2], { _, v -> printf('%s[^%s]\{-}', v, v) }), '')
  let pattern = substitute(pattern . chars[-1], '\*\*', '*', 'g')
  return pattern
endfunction

function! cactus#internal#filter#regex(query) abort
  return a:query
endfunction
