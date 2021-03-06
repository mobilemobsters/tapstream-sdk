﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Windows.Foundation;
using System.Runtime.InteropServices.WindowsRuntime;

namespace TapstreamMetrics.Sdk
{
    public sealed class Tapstream : Api
    {
        private class DelegateImpl : Delegate
        {
            public int GetDelay()
            {
                return 0;
            }

            public bool IsRetryAllowed()
            {
                return false;
            }
        }

        private Delegate del;
        private Platform platform;
        private CoreListener listener;
        private Core core;

        public Tapstream(OperationQueue queue, string accountName, string developerSecret, string hardware)
        {
            del = new DelegateImpl();
            platform = new PlatformImpl();
            listener = new CoreListenerImpl(queue);
            core = new Core(del, platform, listener, accountName, developerSecret, hardware);
        }

        public void FireEvent(Event e)
        {
            core.FireEvent(e);
        }

        public IAsyncOperation<Response> FireHitAsync(Hit h)
        {
            return core.FireHitAsync(h);
        }

        public void SetResponseStatus(int status)
        {
            ((PlatformImpl)platform).response = new Response(status, String.Format("Http %d", status));
        }

        public string[] GetSavedFiredList()
        {
            if (((PlatformImpl)platform).savedFiredList == null)
            {
                return new string[] {};
            }
            return ((PlatformImpl)platform).savedFiredList.ToArray();
        }

        public int GetDelay()
        {
            return core.GetDelay();
        }

        public string GetPostData()
        {
            return core.GetPostData();
        }
    }
}
