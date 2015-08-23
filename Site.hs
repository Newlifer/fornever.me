--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Text.Pandoc.Options
import           Hakyll

--------------------------------------------------------------------------------
feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration {
                      feedTitle = "Friedrich von Never blog",
                      feedDescription = "Friedrich von Never: Engineer, Programmer, Gentleman.",
                      feedAuthorName = "Friedrich von Never",
                      feedAuthorEmail = "friedrich@fornever.me",
                      feedRoot = "https://fornever.me"
                    }

pandoc :: Compiler (Item String)
pandoc = pandocCompilerWith readerOptions writerOptions
    where
        readerOptions = (def ReaderOptions) { readerSmart = True }
        writerOptions = def WriterOptions

main :: IO ()
main = hakyll $ do
    match ("images/*" .||. "fonts/*") $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*.less" $
        compile getResourceBody

    d <- makePatternDependency "css/*.less"
    rulesExtraDependencies [d] $ create ["css/main.css"] $ do
        route idRoute
        compile $ loadBody "css/main.less"
            >>= makeItem
            >>= withItemBody
              (unixFilter "lessc" ["--include-path=css", "-"])

    match (fromList ["about.rst", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandoc
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandoc
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Посты"               `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "int 20h"             `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

    create ["rss.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx
            posts <- fmap (take 10) . recentFirst =<< loadAll "posts/*"
            renderRss feedConfiguration feedCtx posts


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%Y.%m.%d" `mappend`
    defaultContext