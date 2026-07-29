/** <!--
 *
 *  Copyright (C) 2017 veyesys support@veyesys.com
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  If you would like this software to be made available to you under an 
 *  alternate commercial license please email support@veyesys.com 
 *  for more information.
 *
 * -->
 */


#include <cstdio>
#include <cstring>
#include <map>
#include <string>

#include "mediaserver.hpp"

/* html5stream (AQ-VISION) C SDK */
#include "mk_mediakit.h"

using namespace std;

/* Default listen ports for the embedded media server */
#define VE_MEDIA_RTSP_PORT 554
#define VE_MEDIA_RTMP_PORT 1935
#define VE_MEDIA_HTTP_PORT 80

class VEMediaChannel
{
public:
	VEMediaChannel(Factory &pFactory, std::string strId, int nStreamId);
	~VEMediaChannel();

public:
	static bool InitMediaServer();

public:
	void DataHandler1(VideoFrame& frame);
	static void DataHandler(VideoFrame& frame, void * pParam);

private:
	std::string m_strId;
	int m_nStreamId;
	bool m_bFirstFrame;

	Factory &m_pFactory;
	mk_media m_media;
};

bool VEMediaChannel::InitMediaServer()
{
	mk_config config;
	memset(&config, 0, sizeof(config));
	config.ini = NULL;
	config.ini_is_path = 1;
	config.log_level = 0;
	config.log_mask = LOG_CONSOLE;
	config.log_file_path = NULL;
	config.log_file_days = 0;
	config.ssl = NULL;
	config.ssl_is_path = 1;
	config.ssl_pwd = NULL;
	config.thread_num = 0;

	mk_env_init(&config);

	mk_rtsp_server_start(VE_MEDIA_RTSP_PORT, 0);
	mk_rtmp_server_start(VE_MEDIA_RTMP_PORT, 0);
	mk_http_server_start(VE_MEDIA_HTTP_PORT, 0);

	return true;
}

VEMediaChannel::VEMediaChannel(Factory &pFactory, std::string strId, int nStreamId)
:m_strId(strId), m_nStreamId(nStreamId), m_bFirstFrame(true),
m_pFactory(pFactory), m_media(NULL)
{
	printf("Device ID %s  Stream %d\n", strId.c_str(), m_nStreamId);

	/* Create the media source (rtsp/rtmp/http-flv are published automatically) */
	m_media = mk_media_create("__defaultVhost__", "live", m_strId.c_str(), 0, 0, 0);

	/* H264 track; SPS/PPS and resolution are parsed from the stream */
	codec_args v_args;
	memset(&v_args, 0, sizeof(v_args));
	mk_track v_track = mk_track_create(MKCodecH264, &v_args);
	mk_media_init_track(m_media, v_track);
	mk_media_init_complete(m_media);
	mk_track_unref(v_track);

	if (m_nStreamId == 1)
	{
		m_pFactory.RegDataCallback(m_strId,
		(CameraDataCallbackFunctionPtr)VEMediaChannel::DataHandler, 
			(void *)this);
	}
	else if (m_nStreamId == 2)
	{
		m_pFactory.RegSubDataCallback(m_strId,
		(CameraDataCallbackFunctionPtr)VEMediaChannel::DataHandler, 
			(void *)this);
	}else 
	{
		m_pFactory.RegDataCallback(m_strId,
		(CameraDataCallbackFunctionPtr)VEMediaChannel::DataHandler, 
			(void *)this);
	}
}
VEMediaChannel::~VEMediaChannel()
{
	if (m_nStreamId == 1)
	{
		m_pFactory.UnRegDataCallback(m_strId, (void *)this);
	}
	else if (m_nStreamId == 2)
	{
		m_pFactory.UnRegSubDataCallback(m_strId, (void *)this);
	}else 
	{
		m_pFactory.UnRegDataCallback(m_strId, (void *)this);
	}

	if (m_media)
	{
		mk_media_release(m_media);
		m_media = NULL;
	}
}

void VEMediaChannel::DataHandler1(VideoFrame& frame)
{
	/* Process the video frame for media server */
	switch (frame.streamType)
	{
		case VIDEO_STREAM_VIDEO:
			break;
		case VIDEO_STREAM_AUDIO:
			return ;
		default:
		   	return;
	};	

	CodecType current;
	bool bIsKeyFrame = false;

	u8  *dataBuf = NULL;
	u32 dataSize = 0;

	switch (frame.frameType)
	{
		case VIDEO_FRM_I:
		{
			dataBuf = frame.dataBuf + sizeof(InfoFrameI);
			dataSize = frame.dataLen - sizeof(InfoFrameI);
			InfoFrameI *pI = (InfoFrameI *)frame.dataBuf;

			current = (CodecType)pI->video;

			if (current == CODEC_NONE)
			{
				return;
			}
			/* Current only support H264 */
			if (current != CODEC_H264)
			{
				return;
			}
			bIsKeyFrame = true;
			break;
		}
		case VIDEO_FRM_P:
		{
			dataBuf = frame.dataBuf + sizeof(InfoFrameP);
			dataSize = frame.dataLen - sizeof(InfoFrameP);
			InfoFrameP *pP = (InfoFrameP *)frame.dataBuf;
			current = (CodecType)pP->video;

			if (current == CODEC_NONE)
			{
				return;
			}
			/* Current only support H264 */
			if (current != CODEC_H264)
			{
				return;
			}
			break;
		}
		default:
		   	return;
	};

	/* Wait for the first key frame before feeding the stream */
	if (m_bFirstFrame == true)
	{
		if (bIsKeyFrame == false)
		{
			printf("Have not get I frame skip\n");
			return;
		}
		m_bFirstFrame = false;
	}

	if (m_media == NULL || dataBuf == NULL || dataSize == 0)
	{
		return;
	}

	/*
	 * The buffer is an Annex-B H264 access unit (with start codes).
	 * mk_media_input_h264 splits NALUs and parses SPS/PPS internally.
	 * dts/pts = 0 lets the library generate timestamps.
	 */
	mk_media_input_h264(m_media, dataBuf, dataSize, 0, 0);

	return;
}

void VEMediaChannel::DataHandler(VideoFrame& frame, void * pParam)
{
    VEMediaChannel *pObject = static_cast<VEMediaChannel *> (pParam);
    
    return pObject->DataHandler1(frame);
}



VEMediaServer::VEMediaServer(Factory &pFactory)
:m_pFactory(pFactory)
{
	InitDevices();
}
VEMediaServer::~VEMediaServer()
{
	
}

bool VEMediaServer::DeviceChangeCallbackFunc(void* pData, 
								FactoryCameraChangeData change)
{
	if (pData)
	{
		VEMediaServer * pthread = (VEMediaServer *)pData;
		pthread->DeviceChangeCallbackFunc1(change);
	}
	return true;
}
bool VEMediaServer::DeviceChangeCallbackFunc1(FactoryCameraChangeData change)
{
	VDC_DEBUG( "Media Server Device Change Callback %s type %d Begin\n", change.id.c_str(), change.type);
	
	if (change.type == FACTORY_CAMERA_OFFLINE)
	{
		DeleteOneDevice(change.id);
	}
	if (change.type == FACTORY_CAMERA_ONLINE)
	{
		VidCamera  pParam;
		if (m_pFactory.GetConfDB().GetCameraConf(change.id, pParam) == true)
		{
			if (pParam.bservermotion() == true)
			{
				InitOneDevice(pParam);
			}
		}
	}
	VDC_DEBUG( "Media Server Change Callback %s type %d End \n", change.id.c_str(), change.type);

	return true;
}

bool VEMediaServer::InitDevices()
{	
	VidCameraList pCameraList;
	
	//TODO Check if online
	m_pFactory.GetCameraList(pCameraList);

	int cameraSize = pCameraList.cvidcamera_size();

	for (s32 i = 0; i < pCameraList.cvidcamera_size(); i ++)
	{
		VidCamera cam = pCameraList.cvidcamera(i);
		InitOneDevice(cam);
	}
	return true;
}


bool VEMediaServer::DeleteOneDevice(astring strId)
{
	VEMediaChannelMap::iterator it = m_ChannelMap.begin();
	for(; it!=m_ChannelMap.end(); ++it)
	{
		if ((*it).first == strId)
		{
			delete (*it).second;
			m_ChannelMap.erase(it);
			break;
		}
	}
	return true;
}

bool VEMediaServer::InitOneDevice(VidCamera  pParam)
{
	VEMediaChannel *pChn = new VEMediaChannel(m_pFactory, pParam.strid(), 0);

	m_ChannelMap[pParam.strid()] = pChn;

	return true;
}


bool VEMediaServer::InitMediaServer()
{
	return VEMediaChannel::InitMediaServer();
}


