﻿module ForneverMind.Common

open System
open System.IO

open Arachne.Http
open Freya.Core
open Freya.Machine
open Freya.Machine.Extensions.Http

let private utf8 = Freya.init [ Charset.Utf8 ]
let private json = Freya.init [ MediaType.Html ]

let rss = MediaType (Type "application", SubType "rss+xml", Parameters Map.empty)

let methods = Freya.init [ GET; HEAD ]

let machine =
    freyaMachine {
        using http
        charsetsSupported utf8
        mediaTypesSupported json
    }

let pathIsInsideDirectory directory path =
    let fullDirectory = Path.GetFullPath directory
    let fullPath = Path.GetFullPath path
    fullPath.StartsWith fullDirectory

let dateTimeToSeconds (date : DateTime) =
    let d = date.ToUniversalTime ()
    DateTime(d.Year,
             d.Month,
             d.Day,
             d.Hour,
             d.Minute,
             d.Second,
             DateTimeKind.Utc)

let initLastModified = dateTimeToSeconds >> Freya.init
