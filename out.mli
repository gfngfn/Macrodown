(* signature for out.ml *)
  open Types
  exception IllegalOut of string

  val main : abstract_tree -> string
