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
  type subst =
    | Char of string
    | Word of string

  let word s = Word s
  let char s = Char s

  type t = subst M.t

  let empty = M.empty
  let add key value mapping = M.add key value mapping
  let from_list list = M.of_list list

  let from_list' f =
    List.fold_left (fun map (key, value) -> add (f key) value map) empty
  ;;

  let concat a b = M.union (fun _ _ k -> Some k) a b
  let add = M.add
  let update = M.update
  let remove = M.remove
  let map_char s l = l |> List.map (fun x -> x, char s)

  let special_chars =
    let groups =
      [ map_char "a" [ 224; 225; 226; 227; 228; 229 ]
      ; map_char "e" [ 232; 233; 234; 235 ]
      ; map_char "i" [ 236; 237; 238; 239 ]
      ; map_char "o" [ 242; 243; 244; 245; 246; 240 ]
      ; map_char "oe" [ 248 ]
      ; map_char "u" [ 249; 250; 251; 252 ]
      ; map_char "ae" [ 230 ]
      ; map_char "c" [ 231 ]
      ; map_char "n" [ 241 ]
      ; map_char "y" [ 253; 255; 7923 ]
      ; map_char "A" [ 192; 193; 194; 195; 196; 197 ]
      ; map_char "E" [ 200; 201; 202; 203 ]
      ; map_char "I" [ 204; 205; 206; 207 ]
      ; map_char "O" [ 210; 211; 212; 213; 214 ]
      ; map_char "OE" [ 216 ]
      ; map_char "U" [ 217; 218; 219; 220 ]
      ; map_char "AE" [ 198 ]
      ; map_char "C" [ 199 ]
      ; map_char "N" [ 209 ]
      ; map_char "Y" [ 221 ]
      ]
    in
    let extras =
      [ 223, char "ss"; 208, char "D"; 240, char "d"; 215, char "x" ]
    in
    from_list' Uchar.of_int (List.flatten groups @ extras)
  ;;

  let known_chars =
    concat
      (from_list'
         Uchar.of_char
         [ '+', word "plus"
         ; '&', word "and"
         ; '@', word "at"
         ; '%', word "percent"
         ; '#', word "sharp"
         ; '$', word "dollar"
         ])
      (from_list'
         Uchar.of_int
         [ 8364, word "euro"; 163, word "pound"; 165, word "yen" ])
  ;;

  let default = concat special_chars known_chars
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
    let () =
      if (not share_char) && not is_leading_sequence
      then Buffer.add_string buf unknown
    in
    is_leading_sequence, Separator
;;

let cons_unknown ~share_char ~sep buf (is_leading_sequence, state) =
  match state with
  | Fresh -> is_leading_sequence, Unknown
  | Unknown -> is_leading_sequence, Unknown
  | Separator ->
    let () =
      if (not share_char) && not is_leading_sequence
      then Buffer.add_string buf sep
    in
    is_leading_sequence, Unknown
;;

let handle_unregular_char ~mapping ~share_char ~sep ~unknown buf str i state =
  match String.get_utf_8_uchar str i |> Uchar.utf_decode_uchar with
  | uchar ->
    (match M.find_opt uchar mapping with
     | Some (Mapping.Char subst) ->
       (* Found, we can handle it as a regular char. *)
       cons_regular_chars ~sep ~unknown buf subst state
     | Some (Mapping.Word subst) ->
       (* Found, we can handle it as a regular char. *)
       state
       |> cons_space ~share_char ~unknown buf
       |> cons_regular_chars ~sep ~unknown buf subst
       |> cons_space ~share_char ~unknown buf
     | None ->
       (try
          let _ = Uchar.to_char uchar in
          (* Not found, it is an unknown char. *)
          cons_unknown ~share_char ~sep buf state
        with
        | _ ->
          (* HACK: if the char is not representable,
             it is maybe an accent. Erg. *)
          state))
  | exception _ ->
    (* KLUDGE: Handle exception as discarding char (eg: for accent) *)
    cons_unknown ~share_char ~sep buf state
;;

let from_string
      ?(lowercase = true)
      ?(mapping = Mapping.default)
      ?(sep = "-")
      ?(unknown = "-")
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
  let res = Buffer.contents buf in
  if lowercase then String.lowercase_ascii res else res
;;

let to_string x = x
