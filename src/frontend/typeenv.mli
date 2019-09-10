open Types

type t

type type_scheme = BoundID.t list * poly_type

type type_definition =
  | Data  of int
  | Alias of type_scheme

exception IllegalNumberOfTypeArguments    of Range.t * type_name * int * int
exception UndefinedTypeName               of Range.t * module_name list * type_name * type_name list
exception UndefinedTypeArgument           of Range.t * var_name * var_name list
exception CyclicTypeDefinition            of (Range.t * type_name) list
exception MultipleTypeDefinition          of Range.t * Range.t * type_name
exception NotProvidingValueImplementation of Range.t * var_name
exception NotProvidingTypeImplementation  of Range.t * type_name
exception NotMatchingInterface            of Range.t * var_name * t * poly_type * t * poly_type
exception UndefinedModuleName             of Range.t * module_name * module_name list
(*
exception UndefinedModuleNameList         of module_name list
*)

val initialize_id : unit -> unit

val empty : t

val add_macro : t -> ctrlseq_name -> (macro_type * EvalVarID.t) -> t

val find_macro : t -> ctrlseq_name -> (macro_type * EvalVarID.t) option

val add : t -> var_name -> (poly_type * EvalVarID.t * stage) -> t

val find : t -> (module_name list) -> var_name -> Range.t -> (poly_type * EvalVarID.t * stage) option

val find_candidates : t -> (module_name list) -> var_name -> Range.t -> var_name list

val open_module : t -> Range.t -> module_name -> t

val enter_new_module : t -> module_name -> t

val leave_module : t -> t

val add_mutual_cons : t -> level -> untyped_mutual_variant_cons -> t

val find_constructor : pre -> t -> constructor_name -> (mono_type list * TypeID.t * mono_type) option

val find_constructor_candidates : pre -> t -> constructor_name -> constructor_name list

val enumerate_constructors : pre -> t -> TypeID.t -> (constructor_name * (mono_type list -> mono_type)) list

val fix_manual_type_free : pre -> t -> manual_type -> constraints -> mono_type

val find_type_id : t -> module_name list -> type_name -> Range.t -> TypeID.t option

val find_type_name : t -> TypeID.t -> type_name

val sigcheck : Range.t -> pre -> t -> t -> manual_signature option -> t

module Raw : sig
  val fresh_type_id : string -> TypeID.t
  val add_constructor : constructor_name -> type_scheme -> TypeID.t -> t -> t
  val register_type : type_name -> TypeID.t -> type_definition -> t -> t
end

module ModuleInterpreter : sig
  module M : sig
    type ty = type_scheme
    type poly = poly_type
    type kind = int
    type var = TypeID.t

    val var_compare : var -> var -> int
  end

  include sig
    module SS : sig
      type t
      type ex_t
      type label

      module Exist : sig
        type 'a t
        val merge : ('a -> 'b -> 'c) -> 'a t -> 'b t -> 'c t
      end

      module VMap : Map.S
    end

    val from_tyenv : t -> SS.ex_t
    val from_manual : pre -> t -> manual_signature -> SS.ex_t

    exception DuplicateSpec           of Range.t * SS.label
    exception ValueSpecMismatch       of Range.t * SS.label list * t * poly_type * poly_type
    exception ArityMismatch           of Range.t * SS.label list * int * int
    exception TypeMismatch            of t * poly_type * poly_type
    exception MissingImplementation   of Range.t * SS.label
    exception NotProvidingRealization of Range.t * SS.label list * SS.label

    module VMap = SS.VMap

    val subtype_of : Range.t -> SS.label list -> t -> SS.t -> SS.t -> unit
    val matches : Range.t -> t -> SS.t -> SS.ex_t -> type_scheme VMap.t
    val matches_asig : Range.t -> t -> SS.ex_t -> SS.ex_t -> type_scheme VMap.t
  end with module SS = Types.SemanticSig.F(M)
end
