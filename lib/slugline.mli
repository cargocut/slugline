(* Copyright (c) 2026, Cargocut and the Slugline developers.
   All rights reserved.

   SPDX-License-Identifier: BSD-3-Clause *)

(** {b Slugline} is a relatively portable implementation of
    {{:https://en.wikipedia.org/wiki/Clean_URL#Slug} slug} or {i
    speaking URLs}, short identifiers used {only} to name URLs (or
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

  (** {1 Types} *)

  (** Describes a mapping table. *)
  type t

  (** {1 Building a mapping table} *)

  (** Returns an empty mapping table. *)
  val empty : t

  (** [add uchar repr] add the pair [uchar * repr] in the mappping. *)
  val add : Uchar.t -> string -> t -> t

  (** [from_list m] converts an associative list into a mapping table. *)
  val from_list : (Uchar.t * string) list -> t

  (** [from_list' f assoc] converts an associative list into a mapping table
      using [f] on keys. *)
  val from_list' : ('a -> Uchar.t) -> ('a * string) list -> t
end

(** {1 Conversion} *)

val from_string
  :  ?mapping:Mapping.t
  -> ?sep:string
  -> ?unknown:string
  -> string
  -> t

val to_string : t -> string
