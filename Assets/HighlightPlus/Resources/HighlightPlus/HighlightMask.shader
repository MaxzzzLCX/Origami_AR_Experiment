Shader "HighlightPlus/Geometry/Mask" {
Properties {
    _MainTex ("Texture", 2D) = "white" {}
    _Color ("Color", Color) = (1,1,1) // not used; dummy property to avoid inspector warning "material has no _Color property"
    _CutOff("CutOff", Float ) = 0.5
    _Cull ("Cull Mode", Int) = 2
	_ZTest ("ZTest", Int) = 4
}
    SubShader
    {
        Tags { "Queue"="Transparent+100" "RenderType"="Transparent" "DisableBatching"="True" }

        CGINCLUDE

            #include "UnityCG.cginc"
            #include "CustomVertexTransform.cginc"

            sampler2D _MainTex;
      		float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
            fixed _CutOff;
	        UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
				float4 pos: SV_POSITION;
                float2 uv     : TEXCOORD0;
                #if HP_DEPTHCLIP
                    float4 scrPos : TEXCOORD1;
                    float  depth  : TEXCOORD2;
                #endif
                UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
            };

            v2f vert (appdata v)
            {
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_OUTPUT(v2f, o);
                UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.pos = ComputeVertexPosition(v.vertex);
				o.uv = TRANSFORM_TEX (v.uv, _MainTex);
                #if HP_DEPTHCLIP
                    o.scrPos = ComputeScreenPos(o.pos);
                    COMPUTE_EYEDEPTH(o.depth);
                #endif
                #if UNITY_REVERSED_Z
                    o.pos.z += 0.0001;
                #else
                    o.pos.z -= 0.0001;
                #endif
				return o;
            }

            float GetEyeDepth(float rawDepth) {
                float persp = LinearEyeDepth(rawDepth);
                float ortho = (_ProjectionParams.z-_ProjectionParams.y)*(1-rawDepth)+_ProjectionParams.y;
                return lerp(persp,ortho,unity_OrthoParams.w);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
            	#if HP_ALPHACLIP
                	fixed4 col = tex2D(_MainTex, i.uv);
                	clip(col.a - _CutOff);
            	#endif
                #if HP_DEPTHCLIP
                    float sceneZ = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(i.scrPos.xy / i.scrPos.w));
                    float sceneDepth = GetEyeDepth(sceneZ);
                    clip(sceneDepth - i.depth * 0.999);
                #endif
            	return 0;
            }

        ENDCG

        // Create mask
        Pass
        {
			Stencil {
                Ref 2
                Comp always
                Pass replace
                WriteMask 2
                ReadMask 2
            }
            ColorMask 0
            ZWrite Off
            Cull [_Cull]  // default Cull Back improves glow in high quality)
			ZTest [_ZTest]

            CGPROGRAM
            #pragma multi_compile_local _ HP_ALPHACLIP
            #pragma multi_compile_local _ HP_DEPTHCLIP
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

        // Create mask for see-through (the only difference is the ZTest)
        Pass
        {
			Stencil {
                Ref 2
                Comp always
                Pass replace
                WriteMask 2
                ReadMask 2
            }
            ColorMask 0
            ZWrite Off
            Cull [_Cull]  // default Cull Back improves glow in high quality)
			ZTest LEqual

            CGPROGRAM
            #pragma multi_compile_local _ HP_ALPHACLIP
            #pragma multi_compile_local _ HP_DEPTHCLIP
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }


    }
}