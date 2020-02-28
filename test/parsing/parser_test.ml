open Core_kernel
open Main__

let () =
  let trd3 (_, _, z) = z in
  Out_channel.print_endline ";;; generated automatically. DO NOT EDIT";
  Out_channel.print_endline ";;; To update this file, you should run `dune runtest; dune promote`.";
  Sys.argv
  |> Array.to_list
  |> List.tl
  |> Option.value ~default:[]
  |> List.iter ~f:begin fun fn ->
    try
      Out_channel.printf "\n;; %s\n" fn;
      In_channel.with_file fn
        ~f:(fun in_ch ->
            Lexing.from_channel in_ch
            |> ParserInterface.process fn
          )
      |> trd3
      |> [%derive.show: Types.untyped_abstract_tree]
      |> print_endline
    with
    | ParserInterface.Error(rng) ->
      Out_channel.fprintf stderr "%s: parse error: %s\n" Sys.argv.(0) @@ Range.to_string rng;
      exit 1
  end
