import { Preset, FolderStructureInfo } from './Config';
import * as path from "path";

export class MissionPaths {

    static readonly missionSQM = 'mission.Altis.sqm';

    private preset: Preset;

    private folderStructure: FolderStructureInfo;

    private versionUnderscores: string;
    private versionDots: string;

    constructor(preset: Preset,
        folderStructure: FolderStructureInfo,
        versionUnderscores: string,
        versionDots: string) {
        this.preset = preset;
        this.folderStructure = folderStructure;
        this.versionUnderscores = versionUnderscores;
        this.versionDots = versionDots;
    }

    public getMap(): string {
        return this.preset.map;
    }

    public getName(): string {
        return this.preset.missionName;
    }

    // Vindicta
    // Common to all missions, regardless of dev or release build or whatever
    public getNameBase(): string {
        return this.preset.missionNameBase;
    }

    // Vindicta_Altis_v1_2_3
    public getNameMapVersion(): string {
        return (this.getName() + '_' + this.getMap() + '_v' + this.versionUnderscores);
    }

    // Vindicta_Altis_v1_2_3.Altis
    public getNameMapVersionMap(): string {
        return this.getName() + '_' + this.getMap() + '_v' + this.versionUnderscores + '.' + this.getMap();
    }

    // Vindicta_v1
    public getNameVersion(): string {
        return (this.getNameBase() + '_v' + this.versionUnderscores);
    }

    public getBriefingName(): string {
        return (this.getNameBase() + " " + this.versionDots);
    }

    public getWorkDir(): string {
        return this.folderStructure.workDir;
    }

    /**
     * Get path to source mission.sqm file
     */
    public getMissionSqmPath(): string {
        return path.resolve(
            this.folderStructure.missionsFolder,
            'mission.' + this.preset.map + '.sqm'
        );
    }

    /**
     * Get path to folder with mission framework files.
     */
    public getFrameworkPath(): string {
        return path.resolve(this.folderStructure.frameworkFolder);
    }

    /** 
     * Get path to folder containing mission files 
     */
    public getOutputDir(): string {
        return path.resolve(
            this.folderStructure.workDir,
            this.getNameMapVersionMap()
        );
    }

    public getAddonDir(): string {
        return path.resolve(
            this.folderStructure.workDir,
            this.getNameVersion().toLowerCase()
        );
    }

    /*
    Get path to folder within folder which will later be packed into an addon with multiple missions
    */
   public getOutputAddonDir(): string {
       var retval = path.resolve(
            this.getAddonDir(),
            this.getNameMapVersionMap()
        );
        return retval;
    }

    /** 
     * Get path to file with mission configuration.
     * As defined in preset.
     */
    public getMissionConfigFilePaths(): string[] {
        var workDir = this.folderStructure.missionsFolder;
        return this.preset.configFiles.map(function (f) {
            return path.resolve(workDir, f);
        });
    }

}
