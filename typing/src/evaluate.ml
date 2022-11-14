open Ast.TypedAst
let tbl = Hashtbl.create 10;;

let add_var n t =
  Hashtbl.add tbl n t;;

let find_var n =
  Hashtbl.find tbl n;;

let rec eval_typ_desc (position: string) = function
  | Const v ->
    begin match v with
      | VInt _ -> TSeq(TInt, None)
      | VInt32 _ -> TSeq(TInt32, None)
      | VString _ -> TSeq(TString, None)
      | VBool _ -> TSeq(TBool, None)
    end
  | Var s ->
    (* Find the var s *)
    begin
      try
        find_var s
      with
        Not_found -> raise (Error.InvalidType (Format.sprintf "%s| Var with name: %s not found" position s))
    end
  | Fun _ as fn ->
    (* find local variable *)
    let (s, t,ds_t) = 
      match fn with
      | Fun ((s, tt), ds) ->
        let ds_t = eval_typ_desc (position) ds in
        let t =
          match tt with 
          | TSeq (t, None) -> t 
          | _ -> assert false 
        in
        (s, t, ds_t)
      | _ -> assert false
    in

    add_var s (TSeq(t, None));
    TSeq (t, Some ds_t)
  | Op _ -> TSeq (TInt, None)
  | _ -> TSeq(TCustom "", None)

