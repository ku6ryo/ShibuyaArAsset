Shader "Custom/CyberPunk"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _Level("Level", Range(-10, 100)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha 
        LOD 100

        Pass {

          CGPROGRAM
          #pragma vertex vert
          #pragma fragment frag

          #include "UnityCG.cginc"

          static const float TRANSPARENT_MERGIN = 5;

          struct appdata
          {
              float4 vertex : POSITION;
              float2 uv : TEXCOORD0;
          };

          struct v2f
          {
              float2 uv : TEXCOORD0;
              float4 vertex : SV_POSITION;
              float4 worldPos: TEXCOORD1;
          };

          sampler2D _MainTex;
          float4 _MainTex_ST;
          fixed4 _Color;
          float _Level;

          v2f vert (appdata v)
          {
              v2f o;
              o.vertex = UnityObjectToClipPos(v.vertex);
              o.uv = TRANSFORM_TEX(v.uv, _MainTex);
              o.worldPos = mul(unity_ObjectToWorld, v.vertex);
              return o;
          }

          fixed4 frag (v2f i) : SV_Target
          {
              fixed4 col = tex2D(_MainTex, i.uv) * _Color;
              if (i.worldPos.y < _Level) {
                col.a = 1;
              } else if (i.worldPos.y > _Level + TRANSPARENT_MERGIN) {
                col.a = 0;
              } else {
                col.a = 1 - (i.worldPos.y - _Level) / TRANSPARENT_MERGIN;
              }
              return col;
          }
          ENDCG
        }
    }
    FallBack "Diffuse"
}
