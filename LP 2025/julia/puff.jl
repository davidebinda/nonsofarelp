include("huffman.jl")

msg = "brew install emacs"

# hucodec_generate_huffman_tree symbols-n-weights -> huffman-tree
println(conta_caratteri(msg))
hu_tree = hucodec_generate_huffman_tree(conta_caratteri(msg))

# hucodec_generate_symbol_bits_table huffman-tree -> symbol-bits-table
println("\n[v] SIMBOL BITS TABLE")
println(hucodec_generate_symbol_bits_table(hu_tree))

# hucodec_print_huffman_tree huffman-tree indent-level = 0 -> Nothing
println("\n[v] HUFFMAN TREE")
hucodec_print_huffman_tree(hu_tree)

# hucodec_encode message huffman-tree -> bits
println("\n[v] ENCODE MESSAGE")
println(hucodec_encode(['b', 'r', 'e', 'w'], hu_tree))

# hucodec_decode bits huffman-tree -> message
println("\n[v] DECODE MESSAGE")
println(hucodec_decode([1, 0, 0, 1], hu_tree))

# hucodec_encode_file filename huffman-tree -> bits
println("\n[v] ENCODE MESSAGE from FILE")
println(hucodec_encode_file("txt.txt", hu_tree))
