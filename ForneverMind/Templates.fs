﻿module ForneverMind.Templates

open System.IO

open RazorEngine.Configuration
open RazorEngine.Templating

let private razor =
    let templateManager = ResolvePathTemplateManager <| Seq.singleton Config.viewsDirectory
    let config = TemplateServiceConfiguration (DisableTempFileLocking = true, TemplateManager = templateManager)
    RazorEngineService.Create config

let private templatePath name = Path.Combine (Config.viewsDirectory, name + ".cshtml")
let private layoutPath = templatePath "_Layout"

let lastModificationDate name =
    let templateModificationDate = File.GetLastWriteTimeUtc <| templatePath name
    let layoutModificationDate = File.GetLastWriteTimeUtc layoutPath
    max templateModificationDate layoutModificationDate

let render<'a> (name : string) (model : 'a option) : Async<string> =
    async {
        do! Async.SwitchToThreadPool ()
        let value =
            match model with
            | Some(v) -> v
            | None -> Unchecked.defaultof<'a>
        return razor.RunCompile (name, typeof<'a>, value)
    }
