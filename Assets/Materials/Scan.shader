Shader "Custom/Scan"
{
    Properties
    {
        _ColorEdge("Color Edge", Color) = (1, 1, 1, 1)
        _ColorCenter("Color Center", Color) = (1, 1, 1, 1)
        _CenterX("Center X", Range(0, 1000)) = 0
        _CenterZ("Center Z", Range(0, 1000)) = 0
        _Dist("Distance", Range(0, 500)) = 0
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

          static const float HALF_LINE_WIDTH = 2;

          struct appdata
          {
              float4 vertex : POSITION;
              float2 uv : TEXCOORD0;
          };

          struct v2f
          {
              float4 vertex : SV_POSITION;
              float4 worldPos: TEXCOORD1;
          };

          fixed4 _ColorEdge;
          fixed4 _ColorCenter;
          float _CenterX;
          float _CenterZ;
          float _Dist;

          v2f vert (appdata v)
          {
              v2f o;
              o.vertex = UnityObjectToClipPos(v.vertex);
              o.worldPos = mul(unity_ObjectToWorld, v.vertex);
              return o;
          }

          fixed4 frag (v2f i) : SV_Target
          {
              float x = i.worldPos.x - _CenterX;
              float z = i.worldPos.z - _CenterZ;
              float r = sqrt(x * x + z * z);
              fixed4 col = fixed4(0, 0, 0, 0);
              if (r < _Dist + HALF_LINE_WIDTH && r > _Dist - HALF_LINE_WIDTH) {
                float alpha = (1 - abs((r - _Dist) / HALF_LINE_WIDTH));
                col = lerp(_ColorEdge, _ColorCenter, alpha);
                col.a = alpha * 0.5;
              }
              return col;
          }
          ENDCG
        }
    }
    FallBack "Diffuse"
}
