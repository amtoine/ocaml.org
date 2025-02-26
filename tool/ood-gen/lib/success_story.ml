type metadata = {
  title : string;
  logo : string;
  background : string;
  theme : string;
  synopsis : string;
  url : string;
}
[@@deriving of_yaml]

type t = {
  title : string;
  slug : string;
  logo : string;
  background : string;
  theme : string;
  synopsis : string;
  url : string;
  body_md : string;
  body_html : string;
}
[@@deriving
  stable_record ~version:metadata ~remove:[ slug; body_md; body_html ],
    show { with_path = false }]

let of_metadata m = of_metadata m ~slug:(Utils.slugify m.title)

let decode (_, (head, body_md)) =
  let metadata = metadata_of_yaml head in
  let body_html =
    Cmarkit.Doc.of_string ~strict:true body_md |> Cmarkit_html.of_doc ~safe:true
  in
  Result.map (of_metadata ~body_md ~body_html) metadata

let all () = Utils.map_files decode "success_stories"

let template () =
  Format.asprintf
    {|
type t =
  { title : string
  ; slug : string
  ; logo : string
  ; background : string
  ; theme : string
  ; synopsis : string
  ; url : string
  ; body_md : string
  ; body_html : string
  }
  
let all = %a
|}
    (Fmt.brackets (Fmt.list pp ~sep:Fmt.semi))
    (all ())
