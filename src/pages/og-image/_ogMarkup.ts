import type { Node } from "@takumi-rs/core";
import { siteConfig } from "@/site.config";

const logoSvg = `<svg height="60" fill="none" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 272 480"><path fill="#cdffb8" d="M181.334 93.333v-40L226.667 80v40zM136.001 53.333 90.667 26.667v426.666L136.001 480zM45.333 220 0 193.334v140L45.333 360z"/><path fill="#d482ab" d="M90.667 26.667 136.001 0l45.333 26.667-45.333 26.666zM181.334 53.33l45.333-26.72L272 53.33 226.667 80zM136 240l-45.333-26.67v53.34zM0 193.33l45.333-26.72 45.334 26.72L45.333 220zM181.334 93.277 226.667 120l-45.333 26.67z"/><path fill="#2abc89" d="m136 53.333 45.333-26.666v120L226.667 120V80L272 53.333V160l-90.667 53.333v240L136 480V306.667L45.334 360V220l45.333-26.667v73.334L136 240z"/></svg>`;

export const ogMarkup = (title: string, pubDate: string): Node => ({
	type: "container",
	style: {
		backgroundColor: "#1d1f21",
		color: "#c9cacc",
		display: "flex",
		flexDirection: "column",
		height: "100%",
		width: "100%",
	},
	children: [
		{
			type: "container",
			style: {
				display: "flex",
				flex: 1,
				flexDirection: "column",
				justifyContent: "center",
				padding: 40,
				width: "100%",
			},
			children: [
				{
					type: "text",
					text: pubDate,
					style: {
						fontSize: 30,
						marginBottom: 24,
					},
				},
				{
					type: "text",
					text: title,
					style: {
						color: "#ffffff",
						fontSize: 72,
						fontWeight: 700,
						lineHeight: 1.35,
					},
				},
			],
		},
		{
			type: "container",
			style: {
				alignItems: "center",
				borderColor: "#2bbc89",
				borderTopWidth: 1,
				display: "flex",
				fontSize: 24,
				justifyContent: "space-between",
				padding: 40,
				width: "100%",
			},
			children: [
				{
					type: "container",
					style: {
						alignItems: "center",
						display: "flex",
					},
					children: [
						{
							type: "image",
							height: 60,
							src: logoSvg,
						},
						{
							type: "text",
							text: siteConfig.title,
							style: {
								fontWeight: 700,
								marginLeft: 12,
							},
						},
					],
				},
				{
					type: "text",
					text: `by ${siteConfig.author}`,
				},
			],
		},
	],
});
