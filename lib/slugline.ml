(* Copyright (c) 2026, Cargocut and the Slugline developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

type t = string

(* NOTE: A tiny state machine to prevent character repetition. *)
type step =
  | Fresh
  | Separator
  | Unknown

module M = Map.Make (Uchar)

module Mapping = struct
  type t = string M.t

  let empty = M.empty
  let add key value mapping = M.add key value mapping
  let from_list list = M.of_list list

  let from_list' f =
    List.fold_left (fun map (key, value) -> add (f key) value map) empty
  ;;

  let for_repr s l = l |> List.map (fun x -> x, s)

  let special_chars_minus =
    let a =
      [ 192; 193; 194; 195; 196; 197; 224; 225; 226; 227; 228; 229 ]
      |> for_repr "a"
    and e = [ 200; 201; 202; 203; 232; 233; 234; 235 ] |> for_repr "e"
    and i = [ 204; 205; 206; 207; 236; 237; 238; 239 ] |> for_repr "i"
    and o =
      [ 210; 211; 212; 213; 214; 216; 240; 248; 242; 243; 244; 245; 246 ]
      |> for_repr "o"
    and u = [ 217; 218; 219; 220; 249; 250; 251; 252 ] |> for_repr "u"
    and ae = [ 198; 230 ] |> for_repr "ae"
    and c = [ 199; 231 ] |> for_repr "c"
    and n = [ 209; 241 ] |> for_repr "n"
    and y = [ 221; 253; 255 ] |> for_repr "y" in
    from_list'
      Uchar.of_int
      (a @ e @ i @ o @ u @ ae @ c @ n @ y @ [ 223, "b"; 208, "d"; 215, "x" ])
  ;;

  let default_mapping = special_chars_minus
end

let cons_regular_chars ~sep ~unknown buf str (is_leading_sequence, state) =
  let () =
    (* NOTE: Prepend previous separator. *)
    match state with
    | Fresh ->
      (* Regular case, there is no prefix stack. *)
      ()
    | Separator ->
      (* The previous sequence was a separator so we need to add a separator in
         the buffer if the sequence is not leading.*)
      if not is_leading_sequence then Buffer.add_string buf sep
    | Unknown ->
      (* The previous sequence was an unknown char, so we need to add the
         unknown char in the buffer if the sequence is not leading *)
      if not is_leading_sequence then Buffer.add_string buf unknown
  in
  let () = Buffer.add_string buf str in
  false, Fresh
;;

let cons_space ~share_char ~unknown buf (is_leading_sequence, state) =
  match state with
  | Fresh -> is_leading_sequence, Separator
  | Separator -> is_leading_sequence, Separator
  | Unknown ->
    let () = if not share_char then Buffer.add_string buf unknown in
    is_leading_sequence, Separator
;;

let cons_unknown ~share_char ~sep buf (is_leading_sequence, state) =
  match state with
  | Fresh -> is_leading_sequence, Unknown
  | Unknown -> is_leading_sequence, Unknown
  | Separator ->
    let () = if not share_char then Buffer.add_string buf sep in
    is_leading_sequence, Unknown
;;

let handle_unregular_char ~mapping ~share_char ~sep ~unknown buf str i state =
  match String.get_utf_8_uchar str i |> Uchar.utf_decode_uchar with
  | uchar ->
    (match M.find_opt uchar mapping with
     | Some subst ->
       (* Found, we can handle it as a regular char. *)
       cons_regular_chars ~sep ~unknown buf subst state
     | None ->
       (* Not found, it is an unknown char. *)
       cons_unknown ~share_char ~sep buf state)
  | exception _ ->
    (* KLUDGE: Handle exception as an unknown char *)
    cons_unknown ~share_char ~sep buf state
;;

let from_string
      ?(mapping = Mapping.default_mapping)
      ?(sep = "-")
      ?(unknown = "=")
      str
  =
  let share_char =
    (* NOTE: If separators and unknown share the same implementation, we
       collapse them. Other wise, we need to cons the unknown char. *)
    String.equal sep unknown
  in
  let str = String.trim str in
  let len = String.length str in
  let buf = Buffer.create (len * 2) in
  let _ =
    String.fold_left
      (fun (state, i) -> function
         | ('0' .. '9' | 'a' .. 'z' | 'A' .. 'Z') as c ->
           (* We handle a regular char and we increment the counter. *)
           cons_regular_chars ~sep ~unknown buf (String.make 1 c) state, i + 1
         | ' ' | '\t' | '\n' ->
           (* We handle spaces (substitution by [sep]) *)
           cons_space ~share_char ~unknown buf state, i + 1
         | _ ->
           (* A special case that will likely have to fall back on character
              mapping. *)
           ( handle_unregular_char
               ~mapping
               ~share_char
               ~sep
               ~unknown
               buf
               str
               i
               state
           , i + 1 ))
      ( (* NOTE: the flag is used to get the first sequence, avoiding leading
           separators. *)
        (true, Fresh)
      , 0 )
      str
  in
  Buffer.contents buf
;;

let to_string x = x
