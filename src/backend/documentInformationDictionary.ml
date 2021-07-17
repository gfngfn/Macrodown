type document_information_dictionary = {
  title : string option;
  subject : string option;
  author : string option;
  keywords : string list;
}

let registered_document_information_dictionary : document_information_dictionary ref =
  ref {
    title = None;
    subject = None;
    author = None;
    keywords = [];
  }


let register dictionary =
  registered_document_information_dictionary := dictionary


let to_utf16be text = InternalText.to_utf16be (InternalText.of_utf8 text)

let add_to_pdf pdf =
  let document_information_dictionary = !registered_document_information_dictionary in
  let title =
    match document_information_dictionary.title with
    | None -> []
    | Some(title) -> [("/Title", Pdf.String (to_utf16be title))]
  in
  let subject =
    match document_information_dictionary.subject with
    | None -> []
    | Some(subject) -> [("/Subject", Pdf.String (to_utf16be subject))]
  in
  let author =
    match document_information_dictionary.author with
    | None -> []
    | Some(author) -> [("/Author", Pdf.String (to_utf16be author))]
  in
  let keywords =
    let lst = document_information_dictionary.keywords in
    match lst with
    | [] -> []
    | lst -> [("/Keywords", Pdf.String(to_utf16be (String.concat " " lst)))]
  in
  let creator =
    [
      ("/Creator", Pdf.String (to_utf16be "SATySFi"));
      ("/Producer", Pdf.String (to_utf16be "SATySFi"))
    ]
  in
  let information =
    ("/Info", Pdf.Dictionary (title @ subject @ author @ keywords @ creator))
  in
  let dict =
    match pdf.Pdf.trailerdict with
    | Dictionary(lst) -> Pdf.Dictionary(information::lst)
    | d -> d
  in
  {pdf with Pdf.trailerdict = dict}

