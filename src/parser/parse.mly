%{ 
  open Ast.Parsing

  let position (starts, ends) = 
    let open Ast.Common in
    {starts; ends }
%}

%token EOF
%token LET "let" 
%token FUN "fun" 
%token IF "if" 
%token THEN "then" 
%token ELSE "else" 
%token IN "in" 
%token EQUAL "=" 
%token ARROW "->" 
%token DOUBLEDOT ":" 
%token LPARENT "(" 
%token RPARENT ")" 
%token UNIT "()" 
%token <string> IDENT
%token <Ast.Common.values> VALUE

%start <t list>main

%%

main:
  | list(expr_t) EOF
    { $1 }

expr_t:
  | e = expr
   { {expr = e; pos = position ($startofs(e), $endofs(e))} }

expr:
  | "(" e = expr ")" { e }
  | "let" name = IDENT t = typs? "=" e1 = expr_t e2 = let_in_op?
    { LetIn (name, t, e1, e2) }
  | "fun" n = IDENT t = typs? "->" e1 = expr_t
    { Fun (n, t, e1) }
  | "if" e1 = expr_t "then" e2 = expr_t "else" e3 = expr_t
    { IfThen (e1, e2, e3) }
  | v = VALUE
    { Const v }
  | s = syntatic_sugar
    { s }
  | e = var_or_app { e }

var_or_app:
  | n = IDENT e2 = expr_t?
    { 
      match e2 with
      | Some e2 ->
        App ({expr = Var n; pos = position ($startofs(n), $endofs(n))}, e2) 
      | None ->
        Var n
    }
  | e1 = expr e2 = expr
    { App ({expr = e1; pos = position ($startofs(e1), $endofs(e1))}, {expr = e2; pos = position ($startofs(e2), $endofs(e2))}) }

typs:
  | ":" n = separated_list("->", IDENT)
    {
      String.concat "->" n 
    }

let_in_op:
  | "in" e2 = expr_t
    { e2 }

var_typs:
  | n = IDENT t = typs?
    { n, t }


syntatic_sugar:
  | "let" name = IDENT vt = var_typs+ t = typs? "=" e1 = expr_t e2 = let_in_op?
    { 
      let rec list_to_fun = function
        | [] -> e1
        | (a, t) :: tl ->
            {expr = Fun (a, t, list_to_fun tl); pos = position ($startofs(e1), $endofs(e1))}
      in
      LetIn (name, t, list_to_fun vt, e2) 
    }
