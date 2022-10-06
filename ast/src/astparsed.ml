(** AST that we want to parse *)

(** [value] are the possible values for the dyri language *)
type value =
  | VInt of int
  | VString of string
  | VBool of bool
;;

(** [typ] are the possible types for the language *)
type typ =
  | TTyp of string
  | TInference
;;

(** [param] is the params for functions *)
type param =
  | PTyp of (string * typ)
  | PName of string
;;

(** [desc] possible statements to use inside the Dyri language *)
type desc =
  (*  *)
  | Const of value
  | Var of string
  | Apply of (string * desc list)
  | Let of (string * typ * desc)
  | Fun of (string * typ * param list * desc)
  | AnFun of (param list * desc)
  (* need to be implemented *)
  | If
  | For
  | Loop
  | Block of desc list
;;

(** [pos] stores the line and the position of the specific desc *)
type pos = {
  starts: int;
  line: int;
  ends: int;
};;

(** [stmt] this is a stmt, it's created one for each stmt parsed *)
type stmt = {
  pos: pos;
  desc: desc;
};;

(** [code] stores all the AST code from a string/file *)
type code = stmt list
