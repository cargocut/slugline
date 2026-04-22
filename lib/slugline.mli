(* Copyright (c) 2026, Cargocut and the Slugline developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** {b Slugline} is a relatively portable implementation of
    {{:https://en.wikipedia.org/wiki/Clean_URL#Slug} slug} or {i speaking URLs},
    short identifiers used {i only} to name URLs (or
    other keys). The implementation closely resembles. *)

(** The goal of this implementation is to be compact and portable, and it
    draws heavily on the one found in YOCaml. If you're looking for
    more sophisticated and advanced implementations, we encourage you
    to try: {{:https://ocaml.org/p/slug/latest} slug}. *)

(** {1 Types} *)

(** Describes a slug, a [string] whose characters have been replaced. *)
type t

(** {1 Mapping}

    Describes a mapping that explains how to replace invalid
    characters. *)

module Mapping : sig
  (** A mapping is a table that maps {!type:Uchar.t} characters to character
      strings in order to perform a substitution during slug
      conversion. *)

  (** {1 Types and constants} *)

  (** Describes a mapping table. *)
  type t

  (** [subst] is a way to replace things. *)
  type subst =
    | Char of string (** replaced as a char. Ie: [foöo] -> [fooo]. *)
    | Word of string (** replaced as a word. ie: [foöo] -> [fo-o-o]. *)

  (** [char subst] is replaced by inlining (so without spaces). *)
  val char : string -> subst

  (** [word subst] is replaced as a word (so introduce spaces). *)
  val word : string -> subst

  (** A mapping for accentued chars. *)
  val special_chars : t

  (** A mapping that replace some known chars like [+] and [@], usually
      handled by common slug library. *)
  val known_chars : t

  (** The default mapping ([special_chars + const_chars]) used in
      [from_string]. *)
  val default : t

  (** {1 Building a mapping table} *)

  (** Returns an empty mapping table. *)
  val empty : t

  (** [from_list m] converts an associative list into a mapping table. *)
  val from_list : (Uchar.t * subst) list -> t

  (** [from_list' f assoc] converts an associative list into a mapping table
      using [f] on keys. *)
  val from_list' : ('a -> Uchar.t) -> ('a * subst) list -> t

  (** {1 Improving mapping} *)

  (** [concat m1 m2] concat two mappings, if they share substitution, the
      second one will be picked. *)
  val concat : t -> t -> t

  (** [add uchar subst mapping] add the substitution [uchar -> subst] in the
      given [mapping]. *)
  val add : Uchar.t -> subst -> t -> t

  (** [remove uchar mapping] remove [uchar] from the given [mapping]. *)
  val remove : Uchar.t -> t -> t

  (** [update uchar f mapping] update the given [uchar] using [f] on the
      given [mapping]. *)
  val update : Uchar.t -> (subst option -> subst option) -> t -> t
end

(** {1 Conversion} *)

(** [from_string ?lowercase ?mapping ?sep ?unknown subject] converts the
    string [subject] into a slug. The [lowercase] flag (default
    [true]) forces the result to be in lowercase. [mapping] allows
    you to provide your own substitution rules, [sep] is the string
    used to replace spaces, and [unknown] is the string used to
    replace unknown characters. If the separators and placeholders
    are identical, they are merged when they appear consecutively. *)
val from_string
  :  ?lowercase:bool
  -> ?mapping:Mapping.t
  -> ?sep:string
  -> ?unknown:string
  -> string
  -> t

(** [to_string slug] converts the given slug into a string. *)
val to_string : t -> string
