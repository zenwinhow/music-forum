package org.example.springboot.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
@Schema(description = "帖子DTO")
public class PostDTO {
    @Schema(description = "所属版区ID")
    @NotNull(message = "版区ID不能为空")
    private Long sectionId;
    
    @Schema(description = "帖子标题")
    @NotBlank(message = "帖子标题不能为空")
    @Size(min = 2, max = 200, message = "帖子标题长度必须在2到200个字符之间")
    private String title;
    
    @Schema(description = "帖子内容")
    @NotBlank(message = "帖子内容不能为空")
    private String content;

    @Schema(description = "song name")
    private String songName;

    @Schema(description = "artist")
    private String artist;

    @Schema(description = "album")
    private String album;

    @Schema(description = "genre")
    private String genre;

    @Schema(description = "tags")
    private String tags;

    @Schema(description = "cover image url")
    private String coverUrl;

    @Schema(description = "music external url")
    private String musicUrl;
    
    @Schema(description = "是否精华（0-否，1-是）")
    private Integer isEssence;
    
    @Schema(description = "帖子状态（0-删除，1-正常）")
    private Integer status;
} 
