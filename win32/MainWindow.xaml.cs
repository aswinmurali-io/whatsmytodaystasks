// Copyright (C) Microsoft Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

using System;
using System.Windows;
using Microsoft.Web.WebView2.Core;

namespace WebView2WpfBrowser
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        void EnsureHttps(object sender, CoreWebView2NavigationStartingEventArgs args)
        {
            String uri = args.Uri;
            if (!uri.StartsWith("https://"))
            {
                webView.CoreWebView2.ExecuteScriptAsync($"alert('{uri} is not safe, try an https link')");
                args.Cancel = true;
            }
        }

        public MainWindow()
        {
            InitializeComponent();
            webView.NavigationStarting += EnsureHttps;
            InitializeAsync();
        }

        async void InitializeAsync()
        {
            await webView.EnsureCoreWebView2Async(null);
        }
    }
}
