def bm_hash
  Benchmark.benchmark("", 30, "%r\n") do |x|
    hash_aref(x)
    hash_aset(x)
    hash_clear(x)
    hash_delete(x)
    hash_delete_if(x)
    hash_dup(x)
    hash_each(x)
    hash_each_key(x)
    hash_each_value(x)
    hash_equal(x)
    hash_fetch(x)
    hash_flatten(x)
    hash_key(x)
    hash_keys(x)
    hash_length(x)
    hash_merge(x)
    hash_reject(x)
    hash_select(x)
    hash_values(x)
    hash_values_at(x)
  end
end

$small_hash = {
  [[770637937]] => 18,
  [442227972, :E2WngMu6vy] => 5,
  :jaWa => 0,
  :E0R5HN7hX => 14,
  700648627 => 6,
  639030613 => 12,
  348421750 => 16,
  [[:qpMHyZacFmMU]] => 8,
  :SlBkyplxcZ => 17,
  144371495 => 1,
  [596739929] => 9,
  385412024 => 4,
  [673910393] => 19,
  471761289 => 13,
  [:E7, 949213064] => 10,
  :yWcqadXwyg => 3,
  [[[[[:rzW63YCk8, 379991405]]]], 911063042] => 7,
  344267835 => 15,
  :yJjeRw => 11,
  [[[:gIVP], 56874545], [[:d2G1ZCONKq, [884339273, :PA4vYV6dlOv]], [[[[:kI1pIzVGbfuJ], 701032940]], :u7H5]]] => 2,
}

$different_hash = {
  [[77340637937]] => 18,
  14437149335 => 2,
  [59673339929] => 9,
  3854120324 => 5,
  [67391039433] => 1,
  4717612819 => 13,
  [:E7, 9213064] => 1,
  :yWcXwyg => 3,
  [[[[[:r63YCk8, 37999405]]]], 91106042] => 7,
  344267835 => 44,
  :yJjeRw => 33,
  [[[:gIVP], 5555874545], [[:d1ZCONKq, [884339273, :PA4vYV6dlOv]], [[[[:kI1pIzVGbfuJ], 701032940]], :u7H5]]] => 2,
}