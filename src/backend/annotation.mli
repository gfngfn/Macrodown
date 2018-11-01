
open LengthInterface
open GraphicBase


type t =
  | Link of Action.t
  | Screen of Action.t


val register : t -> ((length * length) * length * length * length) -> length -> color option -> unit

val add_to_pdf : Pdf.t -> Pdfpage.t -> Pdfpage.t
